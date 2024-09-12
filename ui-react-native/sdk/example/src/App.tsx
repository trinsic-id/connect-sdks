import { useState } from 'react';
import { StyleSheet, View, Text, Button } from 'react-native';
import { launchSession } from '@trinsic/react-native-ui';
import type { LaunchSessionResult } from '../../src/ReactNativeUi';

const SESSION_CREATE_URL = "https://api.trinsic-development.com/connect/launch-test?redirectSchemeTest=true&noRedirect=true";

export default function App() {
  const [result, setResult] = useState<LaunchSessionResult | null>();
  const [error, setError] = useState<string | null>();

  const handleButtonPress = async () => {
    const getSessionUrlResult = await fetch(SESSION_CREATE_URL);
    const launchUrl = await getSessionUrlResult.text();
    const callbackUrl = 'trinsic-ui-example-redirect-scheme-react-native://callback';
    const result = await launchSession(launchUrl, callbackUrl);
    setResult(result);
  };

  return (
    <View style={styles.container}>
      <Button title="Launch Session"
        onPress={handleButtonPress}
      />
      {!!error && <Text>{error}</Text>}
      {!!result && <>
        <Text>Session ID: {result.sessionId}</Text>
        <Text>Results Access Key: {result.resultsAccessKey}</Text>
        <Text>Success: {result.success ? 'true' : 'false'}</Text>
        <Text>Cancelled: {result.canceled ? 'true' : 'false'}</Text>
      </>}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
