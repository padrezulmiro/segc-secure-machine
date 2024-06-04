# Function to run the Java client, be sure to place in the same directory as where
# IoTClient is ran
run_iot_client() {
  java -classpath ./bin iotclient.IoTDevice 10.101.204.4 ./output/client.truststore ./output/fc55549@alunos.fc.ul.pt/fc55549.keystore fc55549 1 fc55549@alunos.fc.ul.pt &
}

# Number of concurrent instances
num_instances=40

# Run the instances
for i in $(seq 1 $num_instances); do
  run_iot_client
done

# Wait for all background processes to finish
wait

echo "All $num_instances instances of IoTDevice have been executed."

