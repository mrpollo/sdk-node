#!/bin/bash
WORK_DIR="./src"
PROTO_DIR="proto/protos"
SDK_DIR="${WORK_DIR}/dronecode_sdk"
OUT_DIR="./vendor"
JS_IMPORT_STYLE="commonjs"
PROTOS=`find ${PROTO_DIR} -name "*.proto" -type f`

function generate {
  JS_MODULES="";
  JS_EXPORTS="module.exports = {"

  for PROTO_FILE in $PROTOS; do
    MODULE_NAME=`echo $(basename -- ${PROTO_FILE}) | cut -f 1 -d '.'`
    echo "[+] Working on: ${MODULE_NAME}"

    protoc \
      -I$PROTO_DIR \
      --js_out=import_style=commonjs,binary:$OUT_DIR \
      --grpc-web_out=import_style=$JS_IMPORT_STYLE,mode=grpcwebtext:$OUT_DIR \
      $PROTO_FILE

    file_append="const ${MODULE_NAME}_pb = require('./${MODULE_NAME}/${MODULE_NAME}_pb.js');const ${MODULE_NAME}_grpc_web_pb = require('./${MODULE_NAME}/${MODULE_NAME}_grpc_web_pb.js');"
    JS_MODULES=$JS_MODULES$file_append
    JS_EXPORTS=$JS_EXPORTS"${MODULE_NAME}_pb, ${MODULE_NAME}_grpc_web_pb,"
  done
  echo "[+] Building $OUT_DIR/index.js"
  JS_OUT="$JS_MODULES${JS_EXPORTS%?}};"
  touch "$OUT_DIR/index.js"
  echo "$JS_OUT" > "$OUT_DIR/index.js"
  tree $OUT_DIR
}

echo "[+] Generating plugins from "
generate
echo "[+] Done"

