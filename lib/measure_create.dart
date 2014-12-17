import 'dart:async';
import 'dart:html';
import 'package:episodes/episodes.dart';
import 'package:polymer/polymer.dart';

@CustomTag('measure-create')
class MeasureCreate extends PolymerElement {
  @published String numToCreate = '1000';
  @published String tagName = 'div';
  @published int warmupTime = 500;

  bool _testing = false;
  Completer _warmupDone = new Completer();

  MeasureCreate.created() : super.created();

  DivElement get container => $['container'];
  DivElement get drawing => $['drawing'];
  DivElement get status => $['status'];
  ButtonElement get button => $['button'];

  ready() {
    _warmup();
  }

  Future _warmup([Stopwatch watch]) {
    if (watch == null) watch = new Stopwatch()..start();
    if (watch.elapsedMilliseconds > warmupTime) {
      _warmupDone.complete();
      button.disabled = false;
      return new Future(() {});
    } else {
      return test(true).then((_) => _warmup(watch));
    }
  }

  Future<Episodes> testAction() => test();

  Future<Episodes> test([bool warmup = false]) {
    if ((!warmup && !_warmupDone.isCompleted)) {
      return _warmupDone.future.then((_) => test());
    }
    if (_testing) return null;
    button.disabled = true;
    button.text = 'test';
    _testing = true;
    status.innerHtml = 'creating elements...';
    drawing.style.height = '0px';
    return new Future(() {}).then((_) {
      return measureAddingElements(warmup).then((episode) {
        _testing = false;
        button.disabled = false;
        button.text = 'test again';
        drawing.style.height = 'auto';
        status.innerHtml = '';
        return episode;
      });
    });
  }

  Future<Episodes> measureAddingElements(bool warmup) {
    container.innerHtml = '';
    var episode = new Episodes(!warmup, false, false, true);
    episode.clearAllEpisodes();
    episode.clearAllMarks();

    var num = int.parse(numToCreate);
    addElements(num, episode);
    
    status.innerHtml = 'waiting for end of microtask...';
    return new Future.value().then((_) {
      episode.mark('microtask done');
      episode.measure(
          'done -> end of microtask', 'creation done', 'microtask done');
      episode.measure(
          'start -> end of microtask', 'start creating', 'microtask done');
      status.innerHtml = 'cleaning up...';
      return new Future(() {}).then((_) {
        episode.mark('before delete');
        episode.measure('microtask done -> next microtask (rendering?)', 
            'microtask done', 'before delete');
        while(container.firstChild != null) container.firstChild.remove();
        status.innerHtml = 'drawing graph...';
        return new Future(() {}).then((_) {
          episode.mark('delete done');
          episode.measure('delete time', 'before delete', 'delete done');
          if (!warmup) episode.drawEpisodes(drawing, false);
          status.innerHtml = '';
          return new Future(() => episode);
        });
      });
    });
  }

  void addElements(int num, Episodes episode) {
    var elements = createElements(num, episode);
    appendElements(elements, episode);
    episode.measure(
        'create/append $num $tagName\'s', 'start creating', 'appending done');
  }

  List<Element> createElements(int num, Episodes episode) {
    var elements = new List<Element>(num);
    episode.mark('start creating');
    for (int i = 0; i < num; ++i) {
      elements[i] = new Element.tag(tagName);
    }
    episode.mark('creation done');
    episode.measure(
        'create $num $tagName\'s', 'start creating', 'creation done');
    return elements;
  }

  void appendElements(List<Element> elements, Episodes episode) {
    episode.mark('start appending');
    for (Element e in elements) {
      container.append(e);
    }
    episode.mark('appending done');
    episode.measure(
        'append $num $tagName\'s', 'start appending', 'appending done');
  }
}
