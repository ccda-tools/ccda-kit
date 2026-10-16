import React, {useMemo, useState} from 'react';
import {
  ActivityIndicator,
  Image,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import {openCCDAMedia} from '../native';
import {useCCDATheme} from '../theme';
import type {CCDAMedia} from '../types';

export interface CCDAMediaRowProps {
  media: CCDAMedia;
  /** Overrides the built-in native preview, like Android's onOpen callback. */
  onOpen?: (media: CCDAMedia) => void | Promise<void>;
}

const titles: Record<string, string> = {
  imagePNG: 'Image',
  imageJPEG: 'Image',
  imageGIF: 'Image',
  applicationPDF: 'PDF',
  textPlain: 'Text',
  textHTML: 'HTML',
};
const imageMIMEs: Record<string, string> = {
  imagePNG: 'image/png',
  imageJPEG: 'image/jpeg',
  imageGIF: 'image/gif',
};

/** Inline images and attachment actions with built-in platform previews. */
export function CCDAMediaRow({
  media,
  onOpen,
}: CCDAMediaRowProps): React.ReactElement {
  const theme = useCCDATheme();
  const [opening, setOpening] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [failedImage, setFailedImage] = useState<string | null>(null);
  const [availableWidth, setAvailableWidth] = useState(0);
  const [imageSize, setImageSize] = useState<{
    uri: string;
    width: number;
    height: number;
  } | null>(null);
  const styles = useMemo(
    () =>
      StyleSheet.create({
        row: {
          backgroundColor: theme.attachmentBackground,
          borderRadius: theme.cornerRadius,
        },
        action: {padding: 10, gap: 8, minHeight: 44, justifyContent: 'center'},
        pressed: {opacity: 0.7},
        heading: {flexDirection: 'row', alignItems: 'center', gap: 8},
        icon: {color: theme.attachment, fontSize: 20},
        title: {color: theme.text, fontSize: 15, fontWeight: '600', flex: 1},
        meta: {color: theme.muted, fontSize: 12, lineHeight: 18},
        image: {alignSelf: 'flex-start', borderRadius: theme.cornerRadius},
        error: {color: theme.error, padding: 12, paddingTop: 0, fontSize: 13},
      }),
    [theme],
  );
  const {kind} = media.mediaType;
  const title = titles[kind] ?? media.mediaType.mimeType ?? 'Attachment';
  const available = media.payload.kind !== 'unavailable';
  const canOpen = Boolean(onOpen) || (Boolean(titles[kind]) && available);
  const mime = imageMIMEs[kind];
  const imageURI = !mime
    ? null
    : media.payload.kind === 'cachedFile'
    ? media.payload.fileUri
    : media.payload.kind === 'inlineBase64'
    ? `data:${mime};base64,${media.payload.value}`
    : null;

  // Keep inline images within the row and native 180-point maximum. Small
  // attachments retain their natural size instead of reserving a tall box.
  const size = imageSize?.uri === imageURI ? imageSize : null;
  const scale = size
    ? Math.min(1, (availableWidth || 180) / size.width, 180 / size.height)
    : 1;
  const imageDimensions = {
    width: size ? size.width * scale : 1,
    height: size ? size.height * scale : 1,
  };

  async function open(): Promise<void> {
    setOpening(true);
    setError(null);
    try {
      await (onOpen ?? openCCDAMedia)(media);
    } catch (failure) {
      setError(failure instanceof Error ? failure.message : String(failure));
    } finally {
      setOpening(false);
    }
  }

  const content = (
    <>
      {imageURI && imageURI !== failedImage ? (
        <Image
          source={{uri: imageURI}}
          resizeMode="contain"
          style={[styles.image, imageDimensions]}
          accessibilityLabel="Image attachment"
          onLoad={({nativeEvent}) => {
            const {width, height} = nativeEvent.source;
            if (width > 0 && height > 0) {
              setImageSize({uri: imageURI, width, height});
            }
          }}
          onError={() => setFailedImage(imageURI)}
        />
      ) : null}
      <View style={styles.heading}>
        <Text accessible={false} style={styles.icon}>
          ↳
        </Text>
        <Text style={styles.title}>
          {canOpen
            ? `Open ${
                title === 'Text' ? 'text' : title === 'Image' ? 'image' : title
              }`
            : title}
        </Text>
        {opening ? <ActivityIndicator color={theme.attachment} /> : null}
        {canOpen && !opening ? (
          <Text accessible={false} style={styles.icon}>
            ›
          </Text>
        ) : null}
      </View>
      {!available ? (
        <Text style={styles.meta}>Attachment unavailable</Text>
      ) : null}
    </>
  );

  return (
    <View style={styles.row}>
      {canOpen ? (
        <Pressable
          accessibilityRole="button"
          accessibilityLabel={`Open ${title}`}
          accessibilityState={{disabled: opening, busy: opening}}
          disabled={opening}
          onLayout={
            mime
              ? ({nativeEvent}) =>
                  setAvailableWidth(Math.max(1, nativeEvent.layout.width - 20))
              : undefined
          }
          onPress={open}
          style={({pressed}) => [styles.action, pressed && styles.pressed]}>
          {content}
        </Pressable>
      ) : (
        <View style={styles.action}>{content}</View>
      )}
      {error ? (
        <Text accessibilityRole="alert" style={styles.error}>
          {error}
        </Text>
      ) : null}
    </View>
  );
}
