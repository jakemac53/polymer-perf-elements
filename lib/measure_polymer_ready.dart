import 'dart:async';
import 'dart:html';
import 'package:episodes/episodes.dart';
import 'package:polymer/polymer.dart';
import 'measure_create.dart';

@CustomTag('measure-polymer-ready')
class MeasurePolymerReady extends MeasureCreate {
  MeasurePolymerReady.created() : super.created();

  @override
  List<Element> createElements(int num, Episodes episode) {
    var elements = super.createElements(num, episode);

    episode.mark('start calling polymerCreated');
    for (Polymer e in elements) {
      e.polymerCreated();
    }
    episode.mark('done calling polymerCreated');
    episode.measure('polymerCreated 1000 $tagName\'s',
        'start calling polymerCreated', 'done calling polymerCreated');

    // Hacked version of polymer has some extra timing, uncomment when using
    // that.
//    int polymerCreatedTime = 0;
//    int nodeBindTime = 0;
//    int prepareElementTime = 0;
//    int makeElementReadyTime = 0;
//
//    for (Polymer e in elements) {
//      polymerCreatedTime += e.polymerCreatedTime;
//      nodeBindTime += e.nodeBindTime;
//      prepareElementTime += e.prepareElementTime;
//      makeElementReadyTime += e.makeElementReadyTime;
//    }
//
//    var startTime = episode.getMark('start calling polymerCreated');
//    polymerCreatedTime = (polymerCreatedTime / 1000).round() + startTime;
//    nodeBindTime = (nodeBindTime / 1000).round() + startTime;
//    prepareElementTime = (prepareElementTime / 1000).round() + nodeBindTime;
//    makeElementReadyTime = (makeElementReadyTime / 1000).round() + prepareElementTime;
//
//    episode.measure('polymerCreated', startTime, polymerCreatedTime);
//    episode.measure('nodeBind', startTime, nodeBindTime);
//    episode.measure('prepareElement', nodeBindTime, prepareElementTime);
//    episode.measure('makeElementReady', prepareElementTime, makeElementReadyTime);

    return elements;
  }
}
