#! /bin/bash

set -e

VOLUME_NAME=${1:?"Use $0 <environment_folder> to start the development environment"}
FREE_PORT=${2:-8000}
CODE_PORT=${3:-8080}

function extract_payload {
    match=$(grep --text --line-number '^PAYLOAD:$' $0 | cut -d ':' -f 1)
	payload_start=$((match + 1))
    tail -n +$payload_start $0 | tar -xzf -
}

# $1 workdir
function create_dockerfile {
    distro=`jq -cr '.host_distro' ${VOLUME_NAME}/manifest.json`
    extra_pkgs=`jq -r '.extra_pkgs // "" | @sh' ${VOLUME_NAME}/manifest.json`
    sed -e "\
    s/@DISTRO@/${distro}/;\
    s/@EXTRA_PKGS@/${extra_pkgs}/;\
    s/@ENV_FOLDER@/${VOLUME_NAME}/" Dockerfile.template > Dockerfile
}

function create_container {
    if [[ $(docker volume ls --filter "name=${VOLUME_NAME}" -q | wc -l ) -eq 0 ]]; then
        echo "creating volume and copying setup script into it"
        docker volume create --ignore ${VOLUME_NAME}
        docker run -it --rm -v ${VOLUME_NAME}:/workdir busybox \
            /bin/sh -c "mkdir -p /workdir/src && chown -R 1000:1000 /workdir"
    fi

    echo "Building the development container"
    docker build -t ${VOLUME_NAME} -f Dockerfile .
}

function start_container {
    echo "Cleaning up old containers"
    docker rmi $(docker images -qa -f 'dangling=true') || echo "Nothing to remove"

    echo "Starting the development container"
    docker run --rm --cap-add=sys_nice --cap-add=NET_RAW -it -v ${VOLUME_NAME}:/home/yoctouser -p ${FREE_PORT}:8000 -p ${CODE_PORT}:8080 ${VOLUME_NAME}
}

function main {
    extract_payload
    create_dockerfile
    create_container
    rm -rf resources Dockerfile*
    start_container
}

main ${@}
exit 0

PAYLOAD:
�      �kS�H������qW!	���

��N���*�ؘ�5�d'	����	��z~q��[�*2����3���a$�	�I���0�*��ꕒ��NaM7��r�T2*ƚ�������(���Ƭ����^�E���oS�(aC��#���N7p�0^������%����e�l���v*�������Q,�aU���W��v4�J�A�&,�B��"�]�[�<�� #��G��Me����:��bE/V�J����nV����A��^[� "���&�@��G4�}�M׷�$��z{��+���%b(ȇ�7�C��ɒ���� �ܖM}�
P�0J�m�>B< �)�$�sqTHl�2���򄍍)^�)��d�c=P�Sm���$�
c�O���)R&��|�$t��pYs�v�b�%2̦����4b1�����#j�T!���e���B��t��
����.��I������H�Y�u����ve���S�E��w�u���{�����"��c���(��h ���z�����	�VU���;�+l�}�U7 ��{\�_ǒ丌�/�N9h�c5b�$����]�o�<�8�o����f�ň�<��Hl���E��>�F�u�iΓ��B���9��񨑁>0�M\Y&q4<�ԧ�������	rP�!W�!1&���vf�Sq����T吆΂b�.f�=�+n�8!����N����t�e�ل�MH��sEq��l��g��.��ƃG�����p?�Cg�G+�润���M������B��/�(܈�lW�d����dئ������Q��wQ�Z�.b�����H�r\#���)�9Ӧ�+�g��tؓ�N����$��]HYOBh�=m��OϺ���q���+�v���-�o./.�b�B�?���eR�Lq"���fG/s�)ge��ǧG�3S��LVPҳi�s�r��8jHoF*%���r���Ï���|MSAĆ�q�Ɖh�=��?;U�/a~�wTn�b���2^��E��S0
�^�h���e���X� � ����3� _~��_:�a�� �D�!I�1;?F�-�"(>�8�O�f�&�ȑ�B���}�] ��������=�㼹�W��
����%C/+�x�-�����=��f4�\ ���a�ݪ)�D��;f�1^��Mx� 5���#�)/L�)�)�K)dJ�R���'��v�������y%�ږǟ-�gw�a��&�'���j���f�s�:����&�;9,��*2$�y��")�ljTA%"Tܡ��G-G沼����Ar�X�S6�����x+xLK��� ,�����?|��_���ti���vA�U�:tp���ة���>��{�ɟ��);3�y}�L�X�l�[?:Z ���;;�?����L�B��gT3�Yw> iW�-��	bN%ħ]C�ݽ�Q�l�2>��c�}�f~9k׻���wj|)&��Q�Wsؚ��6�Ln��c��bnmK��V���	y}FBP�����=M�3����	��ǻ�b���"8Fo�x�a�9�&�p�YKF���E�N���&,���^����غ�ufG��^�
V���`+X�
~	��p s (  