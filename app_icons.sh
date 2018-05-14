#!/bin/bash

MASTER=$1
OUTPUT_DIR=$2

# iPhone: Spotlight - iOS 7-8 (40pt 2x,3x)
sips -Z 120 ${MASTER} --out ${OUTPUT_DIR}/Icon120.png
sips -Z 80 ${MASTER} --out ${OUTPUT_DIR}/Icon80.png

# iPhone: App - iOS 5,6 (57pt 1x,2x)
sips -Z 114 ${MASTER} --out ${OUTPUT_DIR}/Icon114.png
sips -Z 57 ${OUTPUT_DIR}/Icon114.png --out ${OUTPUT_DIR}/Icon57.png

# iPhone: App - iOS 7,8 (60pt 2x,3x)
sips -Z 180 ${MASTER} --out ${OUTPUT_DIR}/Icon180.png

# iPhone Notifications - iOS 7-10 (20pt 2x,3x)
sips -Z 40 ${MASTER} --out ${OUTPUT_DIR}/Icon40.png
sips -Z 60 ${MASTER} --out ${OUTPUT_DIR}/Icon60.png

# app store (1024)
sips -Z 1024 ${MASTER} --out ${OUTPUT_DIR}/Icon1024.png
