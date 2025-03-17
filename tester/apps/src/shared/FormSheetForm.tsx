import React, { Fragment } from 'react';
import { View, StyleSheet, Dimensions, Button,Pressable } from 'react-native';
import { ThemedText, ThemedTextInput } from '.';
import { useNavigation } from '@react-navigation/native';

const fields = [
  { name: 'formsheet-first-name', placeholder: 'First Name *' },
  { name: 'formsheet-last-name', placeholder: 'Last Name *' },
  { name: 'formsheet-email', placeholder: 'Email *' },
];

export const FormSheetForm = (): React.JSX.Element => {
  const navigation = useNavigation();
  return (
    <Pressable onPress={() => navigation.goBack()} style={styles.container}>
    <View testID="FormSheetForm"  style={styles.wrapper}>
      <ThemedText testID="FormSheetForm-header" style={styles.heading}>
        Example form
      </ThemedText>
      {fields.map(({ name, placeholder }) => (
        <Fragment key={name}>
          <ThemedText testID={`${name}-label`} style={styles.label}>
            {placeholder}
          </ThemedText>
          <ThemedTextInput  testID={`${name}-input`} style={styles.input}/>
        </Fragment>
      ))}
      <Button
        title="Go back"
        onPress={() => {
          navigation.goBack();
        }}
      />
    </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  wrapper: {
    backgroundColor:'#ffffff',
    height: 400,
    paddingTop:20,
    width: '100%',
    position: 'absolute',
    bottom: 0,
  },
  heading: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  label: {
    textTransform: 'capitalize',
    fontSize: 12,
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderRadius: 5,
    marginBottom: 12,
    height: 40,
  },
});
