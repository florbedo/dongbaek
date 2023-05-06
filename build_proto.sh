#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <build|rebuild|clean>"
    exit 1
fi

BASEDIR=$(dirname "$0")
case $1 in
    build)
        mkdir -p $BASEDIR/lib/proto
        protoc -I=$BASEDIR/proto --dart_out="grpc:$BASEDIR/lib/proto" \
            google/protobuf/timestamp.proto \
            google/protobuf/duration.proto \
            $BASEDIR/proto/*.proto
        ;;
    rebuild)
        rm -rf $BASEDIR/lib/proto
        mkdir -p $BASEDIR/lib/proto
        protoc -I=$BASEDIR/proto --dart_out="grpc:$BASEDIR/lib/proto" \
            google/protobuf/timestamp.proto \
            google/protobuf/duration.proto \
            $BASEDIR/proto/*.proto
        ;;
    clean)
        rm -rf $BASEDIR/lib/proto
        ;;
    *)
        "usage: $0 <build|rebuild|clean>"
        exit 1
        ;;
esac
        
