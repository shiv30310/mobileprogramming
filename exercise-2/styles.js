import { DefaultTheme } from 'react-native-paper';

export const theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#6200EE',
    accent: '#03DAC6',
    background: '#F5F5F5',
    surface: '#FFFFFF',
    error: '#B00020',
    text: '#000000',
    onSurface: '#000000',
    disabled: '#9E9E9E',
    placeholder: '#9E9E9E',
    backdrop: '#000000',
    notification: '#FF6D00',
    cardGradientStart: '#6A11CB',
    cardGradientEnd: '#2575FC',
  },
  roundness: 10,
};

export const appStyles = {
  container: {
    flex: 1,
    padding: 8,
    backgroundColor: theme.colors.background,
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
    backgroundColor: theme.colors.primary,
  },
  input: {
    marginVertical: 8,
    backgroundColor: theme.colors.surface,
  },
  button: {
    marginVertical: 8,
  },
  searchbar: {
    margin: 8,
    borderRadius: theme.roundness,
    backgroundColor: theme.colors.surface,
    elevation: 2,
  },
};