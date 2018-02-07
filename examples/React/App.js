/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  Button,
  DeviceEventEmitter,
  ToastAndroid
} from 'react-native';

import Hotword from './src/native/Hotword';


export default class App extends Component {
  constructor(props) {
    super(props);
    this.state = { isRecording: false };
  }

  onPressRecord(isRecording) {

    if(isRecording) {
      Hotword.stop();
    } else {
      Hotword.start();
    }

    this.setState({
      isRecording: !this.state.isRecording
    });
  }

  handleHotwordDetection() {
    ToastAndroid.show('Hossword Detected!', ToastAndroid.SHORT);
  }

  componentDidMount() {
      Hotword.initHotword();
      DeviceEventEmitter.addListener('HOTWORD_DETECTED', (e: Event) => {
        this.handleHotwordDetection();
      });
  }

  componentWillUnmount() {
    Hotword.destroy();
  }

  render() {
    return (
      <View style={styles.container}>
        <View>
          <Text style={styles.welcome}>
            Hey Hoss!
          </Text>
          <Text style={styles.instructions}>
            Say "Hey Hoss" to log detection.
          </Text>
        </View>

        <View style={styles.btnWrapper}>
          <Button
            onPress={() => {this.onPressRecord(this.state.isRecording)}}
            title={ this.state.isRecording ? "Stop" : "Start" }
            color="#841584"
          />
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#F5FCFF',
  },
  btnWrapper: {
    marginLeft: 60,
    marginRight: 60,
    marginTop: 20
  },
  welcome: {
    fontSize: 32,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    fontSize: 24,
    textAlign: 'center',
    color: '#333333',
    marginBottom: 10,
  },
});
