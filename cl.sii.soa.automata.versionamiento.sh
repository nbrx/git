#!/bin/bash
nombreServicio=cl.sii.$1-soa
groupId=$2
JIRA=$3
artifactId=$1

flag=0;
if [[ -n "$nombreServicio" ]]; then
    echo "Nombre del Servicio: $nombreServicio"
    flag=1
else
    flag=0
    echo "ERROR No ha especificado el Nombre del Servicio:"
    echo "ej: [./cl.sii.soa.automata.versionamiento.sh  {objeto}.{objCompuesto}.{adjetivo}.{accion} {GroupID} {NRO-REQ}]"
fi

if [[ -n "$JIRA" ]]; then
    echo "Numero de JIRA: $JIRA"

    if [[ "$flag" = "0" ]]; then
    	flag=0
    else
        flag=1
    fi
else
    flag=0
    echo "ERROR No ha especificado el NRO-REQ.:"
    echo "ej: [./cl.sii.soa.automata.versionamiento.sh  {objeto}.{objCompuesto}.{adjetivo}.{accion} {GroupID} {NRO-REQ}]"
fi

if [[ -n "$groupId" ]]; then
    echo "GroupID: $groupId"

    if [[ "$flag" = "0" ]]; then
    	flag=0
    else
        flag=1
    fi
else
    flag=0
    echo "ERROR No ha especificado el GroupID:"
    echo "ej: [./cl.sii.soa.automata.versionamiento.sh  {objeto}.{objCompuesto}.{adjetivo}.{accion} {GroupID} {NRO-REQ}] "
fi

if [[ $flag = "1" ]]; then
	echo "Creacion Proyecto en GITLAB del Servicio"

 
	curl -X POST --header "PRIVATE-TOKEN: ftiXZNto1AJR6P33Dvpx" -H "Content-Type: application/json" -d '{"description":"'$nombreServicio'","public":false,"archived":false,"visibility_level":10,"ssh_url_to_repo":"git@gitlab:sca/'$nombreServicio'.git","http_url_to_repo":"http://gitlab/sca/'$nombreServicio'.git","web_url":"http://gitlab/sca/'$nombreServicio'","name":"'$nombreServicio'","name_with_namespace":"sca/'$nombreServicio'","path":"'$nombreServicio'","path_with_namespace":"sca/'$nombreServicio'","container_registry_enabled":true,"issues_enabled":true,"merge_requests_enabled":true,"wiki_enabled":true,"builds_enabled":true,"snippets_enabled":false,"star_count":0,"forks_count":0,"open_issues_count":0,"public_builds":true,"shared_with_groups":[],"only_allow_merge_if_build_succeeds":false,"request_access_enabled":false,"only_allow_merge_if_all_discussions_are_resolved":false,"permissions":{"project_access":null,"group_access":{"access_level":50,"notification_level":3}}}' 'http://gitlab/api/v3/projects?private_token=ftiXZNto1AJR6P33Dvpx' -v

	echo "Creancion de Repositorio"

	git clone http://sca@gitlab/sca/$nombreServicio.git
	cd $nombreServicio
	touch README.md
	git add README.md
	git commit -m "Se crea el master productivo del proyecto"
	git push -u origin master
	
	echo "Creacion del Branch : $JIRA"
	git branch $JIRA
	git checkout $JIRA
	echo "Se crea Rama $JIRA para el servicio $nombreServicio" >> README.md
	git add -A
	git commit -m "Se crea Rama $JIRA para el Servicio $nombreServicio en archivo README"
	git push -u origin $JIRA
	
	cd ..
	echo "git clone -b $JIRA --single-branch http://sca@gitlab/sca/$nombreServicio.git $nombreServicio-$JIRA"
	git clone -b $JIRA --single-branch http://sca@gitlab/sca/$nombreServicio.git $nombreServicio-$JIRA
	cd $nombreServicio-$JIRA
	mvn archetype:generate -DgroupId=group.test -DartifactId=$artifactId -DarchetypeGroupId=soa.archetype -DarchetypeArtifactId=mediator-soaapp-archetype -DinteractiveMode=false -DarchetypeVersion=1.0.0
	mv $artifactId/* .
	rm -rf $artifactId
	git add -A
	git commit -m "Se crea proyecto SOA desde Arquetipo mediator-soaapp-archetype "
	
	git push -u origin $JIRA
	
	cd ..
	rm -rf $nombreServicio $nombreServicio-$JIRA
fi

echo $flag

