import 'dart:async';
import 'dart:html';
import 'package:episodes/episodes.dart';
import 'package:polymer/polymer.dart';

@CustomTag('measure-create')
class MeasureCreate extends PolymerElement {
  @published String numToCreate = '1000';
  @published String tagName = 'div';

  bool _testing = false;

  MeasureCreate.created() : super.created();

  DivElement get container => $['container'];
  DivElement get drawing => $['drawing'];
  DivElement get status => $['status'];
  ButtonElement get button => $['button'];

  Future<Episodes> test() {
    if (_testing) return null;
    button.disabled = true;
    button.text = 'test';
    _testing = true;
    status.innerHtml = 'creating elements...';
    drawing.style.height = '0px';
    return new Future(() {}).then((_) {
      return measureAddingElements().then((_) {
        _testing = false;
        button.disabled = false;
        button.text = 'test again';
        drawing.style.height = 'auto';
        status.innerHtml = '';
      });
    });
  }

  Future<Episodes> measureAddingElements() {
    container.innerHtml = '';
    var episode = new Episodes(false, false, false, true);
    episode.clearAllEpisodes();
    episode.clearAllMarks();

    var num = int.parse(numToCreate);
    episode.mark('start creating');
    addElements(num);
    episode.mark('creation done');
    episode.measure(
        'create/append $num $tagName\'s', 'start creating', 'creation done');
    
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
          episode.drawEpisodes(drawing, false);
          status.innerHtml = '';
          return new Future(() => episode);
        });
      });
    });
  }

  void addElements(int num) {
    for (int i = 0; i < num; ++i) {
      container.append(new Element.tag(tagName));
    }
  }
}
