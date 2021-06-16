#!/bin/bash

# create
export testKind=secret
export testReason=created
export namespace=default
export name='dapr-workflows'
#export name='my-secret6'


# update
#export testKind=secret
#export testReason=updated
#export namespace=`echo`
#export name='default/my-secret6'
#export name='default/dapr-workflows'

# delete
#export testKind=secret
#export testReason=deleted
#export namespace=`echo`
#export name='default/my-secret6'
#export name='default/dapr-workflows'

# store as b64 yaml
IFS='/'
read -a strarr <<<"$name"
if [[ $testReason == "created" ]]; then
    echo "Namespace: ${strarr[0]}"
    echo "Secret: ${strarr[1]}"
else
    echo "Namespace: $namespace"
    echo "Secret: $name"
fi

if [[ $testReason == "deleted" ]]; then
    echo "az keyvault secret set-attributes --name k8ssecret-${strarr[0]}-${strarr[1]} --vault-name myiackv --enabled false"
elif [[ $testReason == "updated" ]]; then
    `kubectl get secret -n ${strarr[0]} ${strarr[1]} -o yaml | base64 -w 0 > val-b64.txt`
    echo "az keyvault secret set-attributes --name k8ssecret-${strarr[0]}-${strarr[1]} --vault-name myiackv --enabled true"
    echo "az keyvault secret set --name k8ssecret-${strarr[0]}-${strarr[1]} --vault-name TBDVAULT --file ./val-b64.txt"
else
    `kubectl get secret -n $namespace $name -o yaml | base64 -w 0 > val-b64.txt`
    echo "az keyvault secret set-attributes --name k8ssecret-$namespace-$name --vault-name myiackv --enabled true"
    echo "az keyvault secret set --name k8ssecret-$namespace-$name --vault-name TBDVAULT --file ./val-b64.txt"
fi

#### tested for update
if [[ $testReason == "created" ]]; then
    IFS=$'\n'
    for row in $(kubectl get secret -n $namespace $name -o json | jq '.data')
    do
        if [[ "$row" == *":"* ]]; then
            export keyName=`echo $row | sed 's/:.*//' | sed 's/"//g' | sed 's/ //g'`
            export keyValue=`echo $row | sed 's/^.*://' | sed 's/"//g' | tr -d '\n' | sed 's/ //g' | sed 's/,$//'`
            echo $row
            echo " $keyName and $keyValue"
            `echo $keyValue | base64 --decode > $keyName-kvDec.txt`
            echo "az keyvault secret set --name $namespace-$name-$keyName --vault-name TBDVAULT --file ./$keyName-kvDec.txt"
        fi
    done
fi


if [[ $testReason == "updated" ]]; then
    IFS='/'
    read -a strarr <<<"$name"
    echo "Namespace: ${strarr[0]}"
    echo "Secret: ${strarr[1]}"

    #kubectl get secret -n ${strarr[0]}  ${strarr[1]} -o json | jq '.data'
    IFS=$'\n'
    for row in $(kubectl get secret -n ${strarr[0]}  ${strarr[1]} -o json | jq '.data')
    do
        if [[ "$row" == *":"* ]]; then
            keyName=`echo $row | sed 's/:.*//' | sed 's/"//g' | sed 's/ //g'`
            keyValue=`echo $row | sed 's/^.*://' | sed 's/"//g' | tr -d '\n' | sed 's/ //g' | sed 's/,$//'`
            #echo $row
            #echo " $keyName and $keyValue"
            `echo $keyValue | base64 --decode > $keyName-kvDec.txt`
            echo "az keyvault secret set --name ${strarr[0]}-${strarr[1]}-$keyName --vault-name TBDVAULT --file ./$keyName-kvDec.txt"
        fi
    done
fi

# deleted
if [[ $testReason == "deleted" ]]; then
    IFS='/'
    read -a strarr <<<"$name"
    echo "Namespace: ${strarr[0]}"
    echo "Secret: ${strarr[1]}"

    echo "az keyvault secret list --vault-name myiackv -o json | jq -r '.[] | .name' | grep '^${strarr[0]}-${strarr[1]}-' | sed 's/^\(.*\)$/az keyvault secret set-attributes --name \1 --vault-name myiackv --enabled false/g' | bash" 
fi


