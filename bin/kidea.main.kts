@file:DependsOn("com.github.pgreze:kotlin-process:1.4")

import com.github.pgreze.process.process
import kotlinx.coroutines.runBlocking
import java.io.File
import kotlin.io.path.createSymbolicLinkPointingTo
import kotlin.math.abs
import kotlin.system.exitProcess

fun usage(): String = """
    Usage: kidea your-script.main.kts
    Open main.kts file in a temporary Intellij session.
""".trimIndent()

fun exitWithError(s: String) {
    System.err.println(s)
    exitProcess(1)
}

// kotlinc -script src/kidea.main.kts -- src/kidea.main.kts
fun main() {
    val script = args.getOrNull(0)
        ?.let(::File)
        ?.takeIf { it.name.endsWith(".main.kts") }
    requireNotNull(script) {
        exitWithError("Missing or invalid main.kts script\n\n${usage()}")
    }

    val identifier = script.absolutePath.hashCode().let(::abs).toString()
    val projectDir = File(System.getProperty("user.home"))
        .resolve(".kidea/$identifier-${script.name}")

    val mavenLines = script.useLines { lines ->
        val repositoryMatcher = """^@file:Repository\("([^"]+)"\)""".toRegex()
        val dependsOnMatcher = """^@file:DependsOn\("([^"]+)"\)""".toRegex()
        lines.takeWhile { it.startsWith("import ").not() }.mapNotNull {
            repositoryMatcher.findCapturedGroup(it)?.let(MavenLine::Repository)
                ?: dependsOnMatcher.findCapturedGroup(it)?.let(MavenLine::Dependency)
        }.toList()
    }

    require(projectDir.deleteRecursively()) {
        exitWithError("Could not delete $projectDir")
    }
    projectDir.mkdirs()
    projectDir.resolve("build.gradle.kts")
        .writeText(buildGradle(mavenLines))
    projectDir.resolve("settings.gradle")
        .writeText("rootProject.name = \"${script.name}\"")

    projectDir.resolve("src").let { srcDir ->
        srcDir.mkdir()
        srcDir.resolve(script.name).toPath()
            .createSymbolicLinkPointingTo(script.toPath().toAbsolutePath())
    }

    // TODO: find how to enable its detection.
    // val runConfigName = script.name.replace(".", "_")
    // projectDir.resolve(".idea/runConfigurations/$runConfigName.xml").apply {
    //     parentFile.mkdirs()
    //     RUN_CONFIG.replace("@", "$")
    //         .replace("{script_name}", script.name)
    //         .let(::writeText)
    // }

    runBlocking {
        process("idea", projectDir.absolutePath)
    }
}

sealed class MavenLine(val id: String) {
    class Repository(id: String) : MavenLine(id)
    class Dependency(id: String) : MavenLine(id)
}

fun Regex.findCapturedGroup(input: String): String? =
    find(input)?.groups?.last()?.value

// Notice: kotlin-stdlib-jdk8 is added by default by the plugin.
fun buildGradle(
    mavenLines: Collection<MavenLine>,
    separator: String = "\n" + " ".repeat(8),
): String = """
    plugins {
        kotlin("jvm") version "1.7.10"
    }

    repositories {
        ${mavenLines.toRepsGradleConfig(separator)}
    }

    dependencies {
        implementation(kotlin("stdlib-jdk8"))
        ${mavenLines.toDepsGradleConfig(separator)}
    }
""".trimIndent()

fun Collection<MavenLine>.toRepsGradleConfig(separator: String) =
    filterIsInstance<MavenLine.Repository>()
        .takeIf { it.isNotEmpty() }
        ?.joinToString(separator) { "maven { setUrl(\"${it.id}\") }" }
        ?.let { jetbrainsOnlyMavenCentral + separator + it }
        ?: "mavenCentral()"

val jetbrainsOnlyMavenCentral =
    "mavenCentral { content { includeGroupByRegex(\"org.jetbrains(|.kotlin)\") } }"

fun Collection<MavenLine>.toDepsGradleConfig(separator: String) =
    filterIsInstance<MavenLine.Dependency>()
        .joinToString(separator) { "implementation(\"${it.id}\")" }

main()
