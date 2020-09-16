#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  getNexusImages.sh
# 
#         USAGE:  ./getNexusImages.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  KapitalBank LLC
#       VERSION:  1.0
#       CREATED:  04/01/2020 02:00:31 PM +04
#      REVISION:  ---
#===============================================================================

#imagesOfAtlas=$(nexus-cli image ls | grep atlas)
imagesOfAtlas=$(nexus-cli image ls)
#imagesOfAtlas=$(nexus-cli image tags -name v1/repositories/kblab/ms-teller | head -n 19)

for image in $imagesOfAtlas
#for tag in $imagesOfAtlas
do
    echo '########################################'
    echo "Image name: `echo $image | awk -F '/' '{print $(NF)}'`"
    echo "Image count: `nexus-cli image tags -name $image | tail -n 1 | awk '{ print $3 }'`"
    #nexus-cli image delete -name v1/repositories/kblab/ms-teller -tag $tag
done

#### Look at the tags of the selected Image
# nexus-cli image tags -name v1/repositories/kblab/ms-account
#200306_024448
#200313_110805
#There are 2 images for v1/repositories/kblab/ms-account
#### Look at the layer sizes of the selected TAGGED image:
#➜  nexus-cli image info -name v1/repositories/kblab/ms-account -tag 200306_024448
#Image: v1/repositories/kblab/ms-account:200306_024448
#Size: 7304
#Layers:
#        sha256:fc7181108d403205fda45b28dbddfa1cf07e772fa41244e44f53a341b8b1893d 22489302
#        sha256:73f08ce352c86de44048828a8c20f22011f46efd4d03cab7269354f97b131688 2905854
#        sha256:aea63d497adb0eff8140381f087204abe75558ecb7adc0a7fef0777daeef9fe2 220
#        sha256:b9d35e7964a7711a4202c62b9951020562d1093f5a014f8e9b7a109ca321f283 195214235
#        sha256:67848248bfe69216f3c833d7628e02a1a66004181eb068a6db88267bbc1fb4cb 47255802
#        sha256:45a83f157637ddd1e39a2b478c59698950e3cad1601efe43c5d88099d8f35737 194
#### Remove specific image
#nexus-cli image delete -name IMAGE_NAME -tag TAG
#### To keep only the last X images and delete all other:
#nexus-cli image delete -name IMAGE_NAME -keep X
