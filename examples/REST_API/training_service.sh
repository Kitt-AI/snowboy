#! /usr/bin/env bash
ENDPOINT="https://snowboy.kitt.ai/api/v1/train/"

############# MODIFY THE FOLLOWING #############
TOKEN="??"
NAME="??"
LANGUAGE="en"
AGE_GROUP="20_29"
GENDER="M"
MICROPHONE="??" # e.g., PS3 Eye
############### END OF MODIFY ##################

if [[ "$#" != 4 ]]; then
    printf "Usage: %s wave_file1 wave_file2 wave_file3 out_model_name" $0
    exit
fi

WAV1=`base64 $1`
WAV2=`base64 $2`
WAV3=`base64 $3`
OUTFILE="$4"

cat <<EOF >data.json
{
    "name": "$NAME",
    "language": "$LANGUAGE",
    "age_group": "$AGE_GROUP",
    "token": "$TOKEN",
    "gender": "$GENDER",
    "microphone": "$MICROPHONE",
    "voice_samples": [
        {"wave": "$WAV1"},
        {"wave": "$WAV2"},
        {"wave": "$WAV3"}
    ]
}
EOF

curl -H "Content-Type: application/json" -X POST -d @data.json $ENDPOINT > $OUTFILE
