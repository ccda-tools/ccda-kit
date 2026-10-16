import React, {useEffect, useMemo, useState} from 'react';
import {
  ActivityIndicator,
  Button,
  FlatList,
  Pressable,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import {
  CCDADocumentView,
  parseCCDAXml,
  useCCDATheme,
  type CCDAThemeColors,
  type CCDADocument,
} from '@ccda-tools/react-native';

import {
  NavigationContainer,
  DefaultTheme,
  DarkTheme,
} from '@react-navigation/native';
import {
  createNativeStackNavigator,
  type NativeStackScreenProps,
} from '@react-navigation/native-stack';
import {
  SafeAreaProvider,
  SafeAreaView,
  initialWindowMetrics,
} from 'react-native-safe-area-context';
import {samples, type SampleDocument} from './src/samples';

type ExampleStack = {
  Samples: undefined;
  Document: {filename: string};
};
const Stack = createNativeStackNavigator<ExampleStack>();

function App(): React.JSX.Element {
  const theme = useCCDATheme();
  const navigationTheme = useMemo(
    () => ({
      ...(theme.dark ? DarkTheme : DefaultTheme),
      colors: {
        ...(theme.dark ? DarkTheme : DefaultTheme).colors,
        primary: theme.primary,
        background: theme.pageBackground,
        card: theme.panelBackground,
        text: theme.text,
        border: theme.border,
      },
    }),
    [theme],
  );

  return (
    <SafeAreaProvider initialMetrics={initialWindowMetrics}>
      <StatusBar
        barStyle={theme.dark ? 'light-content' : 'dark-content'}
        backgroundColor={theme.panelBackground}
      />
      <NavigationContainer theme={navigationTheme}>
        <Stack.Navigator
          screenOptions={{
            headerTintColor: theme.primary,
            headerTitleStyle: {color: theme.text},
            headerBackTitleVisible: false,
            contentStyle: {backgroundColor: theme.pageBackground},
          }}>
          <Stack.Screen
            name="Samples"
            component={SampleListScreen}
            options={{title: 'CCDA Examples', headerLargeTitle: true}}
          />
          <Stack.Screen
            name="Document"
            component={SampleDocumentScreen}
            options={({route}) => ({
              title:
                samples.find(
                  sample => sample.filename === route.params.filename,
                )?.title ?? 'Document',
            })}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}

function SampleListScreen({
  navigation,
}: NativeStackScreenProps<ExampleStack, 'Samples'>): React.JSX.Element {
  const theme = useCCDATheme();
  const styles = useMemo(() => createStyles(theme), [theme]);
  return (
    <FlatList
      data={samples}
      contentInsetAdjustmentBehavior="automatic"
      keyExtractor={sample => sample.filename}
      ListHeaderComponent={
        <Text style={styles.listHeader}>
          Select a document · {samples.length} samples
        </Text>
      }
      renderItem={({item}) => (
        <Pressable
          accessibilityRole="button"
          accessibilityLabel={item.title}
          onPress={() =>
            navigation.navigate('Document', {filename: item.filename})
          }
          style={({pressed}) => [
            styles.sampleRow,
            pressed && styles.pressedRow,
          ]}>
          <View style={styles.sampleText}>
            <Text style={styles.sampleTitle}>{item.title}</Text>
            <Text style={styles.source}>{item.source}</Text>
          </View>
          <Text style={styles.chevron} accessibilityElementsHidden>
            ›
          </Text>
        </Pressable>
      )}
    />
  );
}

function SampleDocumentScreen({
  route,
}: NativeStackScreenProps<ExampleStack, 'Document'>): React.JSX.Element {
  const theme = useCCDATheme();
  const sample = samples.find(item => item.filename === route.params.filename);
  return sample ? (
    <SampleDocumentContent key={sample.filename} sample={sample} />
  ) : (
    <Text style={{color: theme.error}} accessibilityRole="alert">
      Sample document unavailable.
    </Text>
  );
}

function SampleDocumentContent({
  sample,
}: {
  sample: SampleDocument;
}): React.JSX.Element {
  const theme = useCCDATheme();
  const styles = useMemo(() => createStyles(theme), [theme]);
  const [document, setDocument] = useState<CCDADocument | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    let active = true;
    async function loadDocument(): Promise<void> {
      setLoading(true);
      setError(null);
      setDocument(null);
      try {
        const parsed = await parseCCDAXml(sample.loadXml());
        if (active) {
          setDocument(parsed);
        }
      } catch (parseError) {
        if (active) {
          setError(
            parseError instanceof Error
              ? parseError.message
              : String(parseError),
          );
        }
      } finally {
        if (active) {
          setLoading(false);
        }
      }
    }
    loadDocument();
    return () => {
      active = false;
    };
  }, [sample, attempt]);

  return (
    <SafeAreaView
      edges={['bottom', 'left', 'right']}
      style={styles.documentScreen}>
      {loading ? (
        <View style={styles.emptyState}>
          <ActivityIndicator color={theme.primary} />
          <Text style={styles.body}>Loading document…</Text>
        </View>
      ) : error ? (
        <View style={styles.emptyState}>
          <Text style={styles.error} accessibilityRole="alert">
            {error}
          </Text>
          <Button
            color={theme.primary}
            title="Retry"
            onPress={() => setAttempt(value => value + 1)}
          />
        </View>
      ) : document ? (
        <CCDADocumentView document={document} />
      ) : null}
    </SafeAreaView>
  );
}

const createStyles = (theme: CCDAThemeColors) =>
  StyleSheet.create({
    documentScreen: {flex: 1},
    listHeader: {padding: 20, color: theme.muted, fontSize: 15},
    sampleRow: {
      flexDirection: 'row',
      alignItems: 'center',
      padding: 18,
      backgroundColor: theme.panelBackground,
      borderBottomWidth: StyleSheet.hairlineWidth,
      borderBottomColor: theme.border,
    },
    pressedRow: {backgroundColor: theme.rowBackground},
    sampleText: {flex: 1, gap: 4},
    sampleTitle: {color: theme.text, fontSize: 17, fontWeight: '600'},
    source: {color: theme.muted, fontSize: 13},
    chevron: {color: theme.primary, fontSize: 24, marginLeft: 12},
    emptyState: {gap: 16, justifyContent: 'center', padding: 24, flex: 1},
    body: {color: theme.text, fontSize: 16, lineHeight: 23},
    error: {color: theme.error, fontSize: 13},
  });

export default App;
