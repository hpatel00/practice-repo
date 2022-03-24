#!/bin/bash

echo 'Apples cost is $100'
echo "Apples cost is \$100"

TRAINING=coding
echo 'Training = ${TRAINING}'
#nothing above is considered a special character so everything is writing as is
echo "Training = ${TRAINING}"
#special characters considered above so TRAINING shows variable
echo Training = ${TRAINING}
