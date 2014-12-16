import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:episodes/src/constants.dart';
import 'package:polymer/polymer.dart';

@CustomTag('perf-test-runner')
class PerfTestRunner extends PolymerElement {
  @published String testTitle;
  @published String testUrl;
  @published int timesToRun = 10;
  @observable bool hidden = true;

  PerfTestRunner.created() : super.created();

  ButtonElement get runButton => $['run'];
  TableElement get results => $['results'];
  DivElement get holder => $['holder'];
  ButtonElement get toggleResults => $['toggleResults'];
  InputElement get timesToRunInput => $['timesToRunInput'];

  ready() {
    timesToRunInput.onChange.listen((_) {
      try{
        timesToRun = int.parse(timesToRunInput.value);
      } catch (e) {
        print(e);
      }
    });
  }

  void toggle() { hidden = !hidden; }

  void runTest() {
    toggleResults.attributes.remove('hidden');
    hidden = false;

    Map<String, List<int>> measures = {};
    runButton.disabled = true;
    _runNextTest(measures).then((_) {
      runButton.disabled = false;
    });
  }

  Future _runNextTest(Map<String, List<int>> measures,
      [testNum = 0, Completer completer]) {
    if (completer == null) completer = new Completer();

    if (testNum >= timesToRun) {
      completer.complete();
      return completer.future;
    };

    holder.innerHtml = '';
    var iframe = new IFrameElement()..src=testUrl;
    holder.append(iframe);

    // Have to wait until the iframe is loaded to start listening, otherwise
    // in dart2js mode we get errors.
    iframe.onLoad.listen((_) {
      var jsIframe = new JsObject.fromBrowserObject(iframe);
      var contentWindow = jsIframe['contentWindow'];
      jsIframe['contentWindow'].callMethod('addEventListener', ['message', (e) {
        if (_handleEpisodeMessage(measures, e)) {
          _updateStats(measures);
          _runNextTest(measures, ++testNum, completer);
        }
      }]);
    });

    return completer.future;
  }

  /**
   * _handleEpisodeMessage is the listener for the Episodes
   * window.postMessage events.
   */
  bool _handleEpisodeMessage(Map<String, List<int>> measures, e) {
    var message = e['data'];
    // Split the message on ':' and make sure the prefix is EPISODES.
    var parts = message.split(':');
    if (parts[0] == PREFIX) {
      var action = parts[1];
      // We only care about the measurements for now.
      if (action == MEASURE) {
        var name = parts[2];
        var time = int.parse(parts[4]) - int.parse(parts[3]);
        if (measures[name] == null) measures[name] = new List<int>();
        measures[name].add(time);
        return false;
      } else if (action == DONE) {
        return true;
      }
    }
    return false;
  }

  void _updateStats(Map<String, List<int>> measures) {
    var resultsBody = results.querySelector('tbody');
    resultsBody.innerHtml = '';
    measures.forEach((String measure, List<int> times) {
      times.sort();

      var mean = 0;
      for (var time in times) mean += time;
      mean = (mean / times.length).floor();

      var median;
      if (times.length == 1) {
        median = times[0];
      } else if (times.length % 2 == 1) {
        median = times[(times.length / 2).floor()];
      } else {
        var half = (times.length / 2).ceil();
        median = (times[half - 1] + times[half]) / 2;
      }
      median = median.floor();

      resultsBody.appendHtml(
          '<tr>'
            '<td>$measure</td><td>$mean</td><td>$median</td>'
            '<td>$times</td>'
          '</tr>');
    });
  }
}
