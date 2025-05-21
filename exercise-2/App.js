import React from 'react';
import { Provider as PaperProvider } from 'react-native-paper';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import DirectoryList from './components/DirectoryList';
import MessageList from './components/MessageList';
import { theme } from './styles';

const Stack = createStackNavigator();

export default function App() {
  return (
    <PaperProvider theme={theme}>
      <NavigationContainer>
        <Stack.Navigator initialRouteName="Directories">
          <Stack.Screen 
            name="Directories" 
            component={DirectoryList} 
            options={{ title: 'Message Store' }}
          />
          <Stack.Screen 
            name="Messages" 
            component={MessageList} 
            options={({ route }) => ({ title: route.params.directory.name })}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </PaperProvider>
  );
}