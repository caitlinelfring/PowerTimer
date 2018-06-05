#!/bin/bash

MASTER=$1
OUTPUT_DIR=$2

# iPhone: Spotlight - iOS 7-8 (40pt 2x,3x)
sips -Z 120 ${MASTER} --out ${OUTPUT_DIR}/Icon120.png
sips -Z 80 ${MASTER} --out ${OUTPUT_DIR}/Icon80.png

# iPhone: App - iOS 7,8 (60pt 2x,3x)
sips -Z 180 ${MASTER} --out ${OUTPUT_DIR}/Icon180.png

# iPhone Notifications - iOS 7-10 (20pt 2x,3x)
sips -Z 40 ${MASTER} --out ${OUTPUT_DIR}/Icon40.png
sips -Z 60 ${MASTER} --out ${OUTPUT_DIR}/Icon60.png

# app store (1024)
sips -Z 1024 ${MASTER} --out ${OUTPUT_DIR}/Icon1024.png

# ipad
sips -Z 20 ${MASTER} --out ${OUTPUT_DIR}/Icon20.png
sips -Z 29 ${MASTER} --out ${OUTPUT_DIR}/Icon29.png
sips -Z 76 ${MASTER} --out ${OUTPUT_DIR}/Icon76.png
sips -Z 152 ${MASTER} --out ${OUTPUT_DIR}/Icon152.png
sips -Z 167 ${MASTER} --out ${OUTPUT_DIR}/Icon167.png
