/*
 * https://github.com/scoverage/sbt-scoverage
 * run tests with coverage: sbt clean coverage test
 * generate coverage reports to target/scoverage-report: sbt coverageReport
 */
addSbtPlugin("org.scoverage" % "sbt-scoverage" % "1.5.1")


/*
 * https://github.com/sksamuel/sbt-scapegoat
 * generate static analysis reports to target/scala-2.11/scapegoat-report: sbt scapegoat
 */
addSbtPlugin("com.sksamuel.scapegoat" %% "sbt-scapegoat" % "1.0.9")