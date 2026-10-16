import {useColorScheme} from 'react-native';

/** Shared visual tokens matching the native CCDATheme palette. */
const light = {
  primary: '#1A6D7A',
  secondary: '#474F9E',
  attachment: '#BD5E1F',
  headerBackground: '#1A6D7A',
  pageBackground: '#F3F6F7',
  panelBackground: '#FFFFFF',
  rowBackground: '#F1F3F5',
  attachmentBackground: '#FFF4E9',
  text: '#182126',
  muted: '#56636B',
  border: '#D5DDE0',
  error: '#B42318',
  onHeader: '#FFFFFF',
  headerMuted: '#D9EDF0',
  headerPill: '#FFFFFF24',
  cornerRadius: 8,
  dark: false,
};

export type CCDAThemeColors = typeof light;

export const CCDATheme: {light: CCDAThemeColors; dark: CCDAThemeColors} = {
  light,
  dark: {
    ...light,
    primary: '#80CCD6',
    secondary: '#B6BAF2',
    attachment: '#F2B17E',
    pageBackground: '#101719',
    panelBackground: '#1C2529',
    rowBackground: '#263237',
    attachmentBackground: '#35291F',
    text: '#EDF3F5',
    muted: '#B0BFC6',
    border: '#415158',
    error: '#FFB4AB',
    dark: true,
  },
};

export function useCCDATheme(): CCDAThemeColors {
  return useColorScheme() === 'dark' ? CCDATheme.dark : CCDATheme.light;
}
