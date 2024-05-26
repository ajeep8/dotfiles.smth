#!/bin/bash
if  [[ $# -eq 0 ]]; then
    echo 'Usage:'
    echo 'pandoc-pptx.sh src.md -o tgt.pptx'
    echo 'pandoc-pptx.sh --reference-doc=ref.pptx src.md -o tgt.pptx'
    exit 1
fi

img="ajeep/pandocone:v3.1.11_p"

num=$#
tgt=${!num}
((num -= 2))
src=${!num}

if [[ $tgt = $src ]]; then
    echo 'target should not same as source!'
    exit 1
fi

srcdir=$(pwd)
#tmpdir=`mktemp -t -d pandocone-XXXXXX`
#cp -af * $tmpdir/
tmpdir=$(pwd)

docker run -it --rm -v $tmpdir:/data \
	-e uid=`id -u` \
	-e mermaid_url=http://192.168.100.199:8170 -e plantuml_url=http://192.168.100.199:8180 -e drawio_url=http://192.168.100.199:8166  -e py2img_url=http://192.168.100.199:8190 \
	$img -d pptx --no-check-certificate \
	$@

#docker run -it --rm -v $tmpdir:/data -e uid=`id -u` -e https_proxy=http://10.222.1.1:7890 pandocone:docx -d pptx $@

#cp $tmpdir/$tgt .
