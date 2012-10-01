// ==UserScript==
// @name           vimus
// @namespace      aeosynth
// @description    vim userscript
// @version        0.0.0
// @copyright      2010 James Campos <james.r.campos@gmail.com>
// @license        MIT; http://en.wikipedia.org/wiki/Mit_license
// @include        *
// ==/UserScript==

(function() {
  var getBOL, getBOW, getEOL, insert, key, keydown, keypress, kill, mode, move, normal;
  key = null;
  mode = null;
  getBOL = function(text, i) {
    var c;
    while ((c = text[--i]) && c !== '\n') {
      ;
    }
    return i + 1;
  };
  getBOW = function(text, i) {
    var c;
    while ((c = text[--i]) && c === ' ' || c === '\n') {
      ;
    }
    while ((c = text[--i]) && c !== ' ' && c !== '\n') {
      ;
    }
    if (i <= 0) {
      return 0;
    } else {
      return i + 1;
    }
  };
  getEOL = function(text, i) {
    var c;
    while ((c = text[++i]) && c !== '\n') {
      ;
    }
    return i;
  };
  keydown = function(e) {
    var kc, _ref;
    if ((_ref = document.activeElement.nodeName) === 'TEXTAREA' || _ref === 'INPUT') {
      mode = insert;
    } else {
      mode = normal;
    }
    kc = e.keyCode;
    switch (kc) {
      case 27:
        return key = '<Esc>';
      default:
        key = e.ctrlKey ? '^' : '';
        return key += String.fromCharCode(kc);
    }
  };
  keypress = function(e) {
    return mode(e);
  };
  kill = function(to) {
    var ae, end, left, length, right, start, text;
    ae = document.activeElement;
    text = ae.value;
    start = ae.selectionStart;
    end = ae.selectionEnd;
    length = ae.textLength;
    switch (to) {
      case 'bol':
        if (text[start - 1] === '\n') {
          start -= 1;
        } else {
          start = getBOL(text, start);
        }
        break;
      case 'bow':
        start = getBOW(text, start);
        break;
      case 'eol':
        if (text[end] === '\n') {
          end += 1;
        } else {
          end = getEOL(text, end);
        }
        break;
      case 'next':
        end += 1;
        break;
      case 'prev':
        if (start !== 0) {
          start -= 1;
        }
    }
    left = text.slice(0, start);
    right = text.slice(end, length);
    ae.value = left + right;
    return ae.setSelectionRange(start, start);
  };
  insert = function(e) {
    var prevent;
    prevent = true;
    switch (key) {
      case '<Esc>':
        document.activeElement.blur();
        break;
      case '^A':
        move('bol');
        break;
      case '^B':
        move('prev');
        break;
      case '^D':
        kill('next');
        break;
      case '^E':
        move('eol');
        break;
      case '^F':
        move('next');
        break;
      case '^H':
        kill('prev');
        break;
      case '^K':
        kill('eol');
        break;
      case '^U':
        kill('bol');
        break;
      case '^W':
        kill('bow');
        break;
      default:
        prevent = false;
    }
    if (prevent) {
      return e.preventDefault();
    }
  };
  move = function(to) {
    var ae, end, len, offset, start, text;
    ae = document.activeElement;
    end = ae.selectionEnd;
    len = ae.textLength;
    start = ae.selectionStart;
    text = ae.value;
    switch (to) {
      case 'bol':
        offset = getBOL(text, start);
        break;
      case 'bow':
        offset = getBOW(text, start);
        break;
      case 'eol':
        offset = getEOL(text, end);
        break;
      case 'next':
        offset = end === len ? end : end + 1;
        break;
      case 'prev':
        offset = start - 1;
    }
    return ae.setSelectionRange(offset, offset);
  };
  normal = function(e) {
    switch (key) {
      case 'G':
        if (e.shiftKey) {
          return window.scrollTo(0, document.height);
        } else {
          return window.scrollTo(0, 0);
        }
        break;
      case 'H':
        return window.scrollBy(-20, 0);
      case 'J':
        return window.scrollBy(0, 20);
      case 'K':
        return window.scrollBy(0, -20);
      case 'L':
        return window.scrollBy(20, 0);
    }
  };
  document.addEventListener('keydown', keydown, true);
  document.addEventListener('keypress', keypress, true);
}).call(this);
