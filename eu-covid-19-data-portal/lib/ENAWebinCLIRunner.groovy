import groovy.json.JsonGenerator

import java.nio.file.Files
import java.nio.file.Path
import java.util.zip.GZIPOutputStream

class ENAWebinCLIRunner {
    final String WEBIN_USER
    final String WEBIN_PASS
    final Path jarPath
    final boolean isTest

    ENAWebinCLIRunner(String WEBIN_USER, String WEBIN_PASS, Path jarPath, boolean isTest) {
        this.WEBIN_USER = WEBIN_USER
        this.WEBIN_PASS = WEBIN_PASS
        this.jarPath = jarPath
        this.isTest = isTest
    }

    Tuple3<ENADropBoxClient.Response, String, String> run(String record_name, Path manifest, Path outputDir) {

        String[] cmd = ([
                "java", "-jar", "${this.jarPath.toAbsolutePath()}",
                "-userName=${WEBIN_USER}", "-passwordEnv=WEBIN_PASS",
                "-manifest=${manifest.toAbsolutePath()}",
                "-inputDir=${manifest.parent.toAbsolutePath()}",
                "-outputDir=${outputDir.toAbsolutePath()}",
                "-context=genome", "-validate", "-submit"]
                + (isTest?["-test",]:[])
        )
        def pb = new ProcessBuilder()
                .directory(outputDir.toAbsolutePath().toFile())
                .command(cmd)
        Map<String, String> env = pb.environment()
        env.put("WEBIN_PASS", WEBIN_PASS)
        def p = new ProcessBuilder(cmd).start()
        def out = new StringBuffer()
        def err = new StringBuffer()
        p.consumeProcessOutput( out, err )
        p.waitFor()
        if(p.exitValue()) {
            throw new IllegalStateException(outputDir.resolve("webin-cli.report").text)
        }
//        def outputItem = outputDir.resolve("genome/${record_name}/")
//
//        Files.copy(
//            outputItem.resolve("submit/analysis.xml"),
//            outputDir.resolve("analysis.xml")
//        )
//        Files.copy(
//            outputItem.resolve("submit/receipt.xml"),
//            outputDir.resolve("receipt.xml")
//        )
//
//        String xml_string = outputDir.resolve("receipt.xml").text

        new Tuple3(
            ENADropBoxClient.parseResponse(outputItem.resolve("submit/analysis.xml").getText(),xml_string),
            outputItem.resolve("submit/receipt.xml").getText(),
            outputDir.resolve("webin-cli.report").getText()
        )

    }

    static void genomeRecordFiles( String  record_name, Map<String, String> genomeRecord, String genomeSequenceString,
                            OutputStream genomeManifest, OutputStream chrFile, OutputStream fastaFile ) {
        def generator = new JsonGenerator.Options()
                .disableUnicodeEscaping()
                .excludeNulls()
                .build()

        fastaFile.with {new GZIPOutputStream(it)}
                .withWriter{ it.write("${record_name} 1 Monopartite") }

        fastaFile.with {new GZIPOutputStream(it)}
                .withWriter{ it.write(">${record_name}\n${genomeSequenceString}") }

        genomeManifest.withWriter {it.write(generator.toJson(
                genomeRecord + [
                        FASTA: fastaFile.getFileName().toString(),
                        CHROMOSOME_LIST: chrFile.getFileName().toString()
                ]
        ))}
    }
}
