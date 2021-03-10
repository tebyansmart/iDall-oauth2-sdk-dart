
import 'dart:html';

void addWebSupport(){
  window.onMessage.forEach((element) {
    print('Event Received in callback: ${element.data}');
  });
}