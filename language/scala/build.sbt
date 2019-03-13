//
// Algorithmia algorithm build file
//

name := "concise-alg-name"

organization := "ons"

// Allow version to be overwritten with "-DalgoVersion=XXX"
version := System.getProperty("algo.version", "1.0-SNAPSHOT")

scalaVersion := "2.11.8"

mainClass in Compile := Some("algorithmia.Main")

val repoUrl = System.getProperty("repo.url", "http://git.algorithmia.com")

resolvers += "Maven Central" at "http://repo1.maven.org/maven2/org/"

resolvers += "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/"

libraryDependencies ++= Seq(
  "com.algorithmia" % "algorithmia-client" % "1.0.+",
  "com.algorithmia" % "algorithmia-extras" % "1.0.+",
  "com.google.code.gson" % "gson" % "2.5"
)

libraryDependencies += "org.scalatest" %% "scalatest" % "3.0.1" % s"$Test, $IntegrationTest"

retrieveManaged := true

// Don't convert name to lowercase
normalizedName := name.value

// for system tests
configs(IntegrationTest)
Defaults.itSettings
