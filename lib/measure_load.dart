import 'dart:async';
import 'dart:html';
import 'package:episodes/episodes.dart';
import 'package:polymer/polymer.dart';

@CustomTag('measure-load')
class MeasureLoad extends PolymerElement {
  final episode = new Episodes();
  bool _willRefresh = false; 
  
  MeasureLoad.created() : super.created();
  
  DivElement get drawing => $['drawing'];
  
  void ready() {
    episode.mark('element-ready');
    episode.measure('element ready', 'starttime', 'element-ready');
    scheduleRefresh();
  }
  
  void mark(String markName, [markTime=null, bool refresh=true]) {
    episode.mark(markName, markTime);
    if (refresh) scheduleRefresh();
  }
  
  void measure(String episodeName, 
      [startNameOrTime=null, endNameOrTime=null, bool refresh=true]) {
    episode.measure(episodeName, startNameOrTime, endNameOrTime);
    if (refresh) scheduleRefresh();
  }
  
  void scheduleRefresh() {
    if (_willRefresh) return;
    _willRefresh = true;
    new Future(() {}).then((_) {
      _willRefresh = false;
      episode.drawEpisodes(drawing);
    });
  }
}
