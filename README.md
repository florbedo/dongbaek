# dongbaek

## How to build

```bash
# install protoc
$ brew install protobuf
# Activate the protoc plugin
$ flutter pub global activate protoc_plugin
# Pull the protobuf files
$ git pull --recurse-submodules
# Generate the protobuf dart files
$ ./build_proto.sh build
# Run with IDE
```
