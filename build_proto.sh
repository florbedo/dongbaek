#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <build|rebuild|clean>"
    exit 1
fi

BASEDIR=$(dirname "$0")
case $1 in
    build)
        mkdir -p $BASEDIR/lib/proto
        protoc -I=$BASEDIR/proto --dart_out=$BASEDIR/lib/proto $BASEDIR/proto/*.proto google/protobuf/timestamp.proto
        ;;
    rebuild)
        rm -rf $BASEDIR/lib/proto
        mkdir -p $BASEDIR/lib/proto
        protoc -I=$BASEDIR/proto --dart_out=$BASEDIR/lib/proto $BASEDIR/proto/*.proto google/protobuf/timestamp.proto
        ;;
    clean)
        rm -rf $BASEDIR/lib/proto
        ;;
    *)
        "usage: $0 <build|clean>"
        exit 1
        ;;
esac
        
