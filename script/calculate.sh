#!/bin/bash

# User Inputs
read -p "Enter current CPU usage per pod (millicores): " CURRENT_CPU
read -p "Enter current RAM usage per pod (MiB): " CURRENT_RAM
read -p "Enter current number of replicas: " CURRENT_REPLICAS
read -p "Enter target CPU utilization (%): " TARGET_CPU_UTIL
read -p "Enter target RAM utilization (%): " TARGET_RAM_UTIL
read -p "Enter min replicas: " MIN_REPLICAS
read -p "Enter max replicas: " MAX_REPLICAS

# Calculate average CPU and RAM usage for all pods
TOTAL_CPU_USAGE=$((CURRENT_CPU * CURRENT_REPLICAS))
TOTAL_RAM_USAGE=$((CURRENT_RAM * CURRENT_REPLICAS))

# Calculate recommended requests based on target utilization
RECOMMENDED_CPU_REQUEST=$((TOTAL_CPU_USAGE * 100 / (CURRENT_REPLICAS * TARGET_CPU_UTIL) ))
RECOMMENDED_RAM_REQUEST=$((TOTAL_RAM_USAGE * 100 / (CURRENT_REPLICAS * TARGET_RAM_UTIL) ))

# Calculate required replicas based on CPU
REQUIRED_CPU_REPLICAS=$(( (TOTAL_CPU_USAGE * 100 / RECOMMENDED_CPU_REQUEST) / TARGET_CPU_UTIL ))

# Calculate required replicas based on RAM
REQUIRED_RAM_REPLICAS=$(( (TOTAL_RAM_USAGE * 100 / RECOMMENDED_RAM_REQUEST) / TARGET_RAM_UTIL ))

# Take the maximum required replicas as the final recommended count
RECOMMENDED_REPLICAS=$(( REQUIRED_CPU_REPLICAS > REQUIRED_RAM_REPLICAS ? REQUIRED_CPU_REPLICAS : REQUIRED_RAM_REPLICAS ))

# Ensure replica count is within limits
if [ "$RECOMMENDED_REPLICAS" -lt "$MIN_REPLICAS" ]; then
    RECOMMENDED_REPLICAS=$MIN_REPLICAS
elif [ "$RECOMMENDED_REPLICAS" -gt "$MAX_REPLICAS" ]; then
    RECOMMENDED_REPLICAS=$MAX_REPLICAS
fi

# Output Results
echo "\n--- HPA Calculation Results ---"
echo "Recommended CPU Request: ${RECOMMENDED_CPU_REQUEST}m"
echo "Recommended RAM Request: ${RECOMMENDED_RAM_REQUEST}Mi"
echo "Recommended Replicas: ${RECOMMENDED_REPLICAS} (Min: $MIN_REPLICAS, Max: $MAX_REPLICAS)"

echo "\n--- Suggested Kubernetes Resources ---"
echo "replicaCount: ${RECOMMENDED_REPLICAS}"
echo "resources:"
echo "  requests:"
echo "    memory: \"${RECOMMENDED_RAM_REQUEST}Mi\""
echo "    cpu: \"${RECOMMENDED_CPU_REQUEST}m\""
echo "  limits:"
echo "    memory: \"$((RECOMMENDED_RAM_REQUEST + RECOMMENDED_RAM_REQUEST / 5))Mi\""
