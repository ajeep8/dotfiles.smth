# How [lua-filters](https://github.com/pandocOne/lua-filters) diagram-generator.lua fetch diagram server

## [mermaid-server](https://github.com/ajeepSave/mermaid-server)

```
curl --noproxy '*' --location -o mmd-post.png --request POST 'http://$mermaidsvr:8170/generate?type=png' \
--header 'Content-Type: text/plain' \
--data-raw 'graph LR

    A-->B
    B-->C
    C-->D
    C-->F
'
```

## [plantuml-server](https://hub.docker.com/r/plantuml/plantuml-server)

```
curl --noproxy '*' --location --request GET 'http://$plantuml_url/png/~hCODEDPLANTUML'
```

## [Kroki](https://github.com/yuzutech/kroki)

Refer to https://docs.kroki.io/kroki/setup/http-clients/

### [mermaid](https://hub.docker.com/r/yuzutech/kroki-mermaid)

```
curl http://$krokisvr:8100/mermaid/png --data-binary '@test.mmd' > kroki-mmd.png

curl --noproxy '*' --location -o kroki-mmd-post.png --request POST 'http://$krokisvr:8100/mermaid/png' \
--header 'Content-Type: text/plain' \
--data-raw 'gantt
dateFormat  YYYY-MM-DD
title Adding GANTT diagram to mermaid
excludes weekdays 2014-01-10

section A section
已完成任务            :done,    des1, 2014-01-06,2014-01-08
Active task               :active,  des2, 2014-01-09, 3d
Future task               :         des3, after des2, 5d
Future task2               :         des4, after des3, 5d
'

curl http://$krokisvr:8100/mermaid/png --data-binary '@test.mmd' > mmd.png
```

### plantuml

```
curl --noproxy '*' --location -o kroki-puml-get.png --request GET http://$krokisvr:8100/plantuml/png/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000

curl --noproxy '*' --location -o kroki-puml-post.png --request POST 'http://$krokisvr:8100/plantuml/png' \
--header 'Content-Type: text/plain' \
--data-raw '@startuml
Bob -> 爱丽丝 : hello
@enduml
'

curl http://$krokisvr:8100/plantuml/png --data-binary '@test.puml' > puml.png
```

### [drawio](https://hub.docker.com/r/yuzutech/kroki-diagramsnet)

```
curl --noproxy '*' --location -o kroki-drawio-post.png --request POST 'http://$krokisvr/diagramsnet/png' \
--header 'Content-Type: text/plain' \
--data-raw '<mxfile......
    ......
</mxfile>
'

cat hubble.drawio | http http://$krokisvr:8100/diagramsnet/png Content-Type:text/plain > drawio1.png

# not function yet
curl http://$krokisvr:8100/diagramsnet/png --data-binary '@test.drawio' > drawio.png 
```

### others

```
cat project.erd | http http://$krokisvr:8100/erd/png Content-Type:text/plain > erd1.png

curl http://$krokisvr:8100/erd/svg --data-binary '@project.erd' > erd.png
```
