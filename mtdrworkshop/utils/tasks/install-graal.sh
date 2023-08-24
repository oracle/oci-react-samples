#!/bin/bash


# Install Graal
while ! state_done GRAAL; do
  if ! test -d ~/graalvm-ce-java11-20.1.0; then
    echo "downloading graalVM"
    curl -sL https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.1.0/graalvm-ce-java11-linux-amd64-20.1.0.tar.gz | tar xz
    mv graalvm-ce-java11-20.1.0 ~/
  fi
  state_set_done GRAAL
  echo "Finished downloading graalVM"
done


# Install GraalVM native-image...
while ! state_done GRAAL_IMAGE; do
  ~/graalvm-ce-java11-20.1.0/bin/gu install native-image
  state_set_done GRAAL_IMAGE
done


state_set_done JAVA_BUILDS