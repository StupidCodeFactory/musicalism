(() => {
  const SVG_NS = 'http://www.w3.org/2000/svg';
  const MAJOR_SPELLINGS = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B'];
  const MINOR_SPELLINGS = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'Bb', 'B'];
  const CIRCLE_OF_FIFTHS = [0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5];
  const OUTER_RADIUS = 205;
  const INNER_RADIUS = 135;

  const keyId = (pitchClass, mode) => `${pitchClass}:${mode}`;
  const parseId = id => { const [pitchClass, mode] = id.split(':'); return { pitchClass: Number(pitchClass), mode }; };
  const spelling = id => { const { pitchClass, mode } = parseId(id); return mode === 'major' ? MAJOR_SPELLINGS[pitchClass] : MINOR_SPELLINGS[pitchClass]; };
  const keyName = id => `${spelling(id)} ${parseId(id).mode}`;
  const shortName = id => parseId(id).mode === 'major' ? spelling(id) : `${spelling(id)}m`;
  const idFromName = name => {
    const [tonic, mode] = name.split(' ');
    const spellings = mode === 'major' ? MAJOR_SPELLINGS : MINOR_SPELLINGS;
    return keyId(spellings.indexOf(tonic), mode);
  };

  function closelyRelated(id) {
    const { pitchClass, mode } = parseId(id);
    if (mode === 'major') return [keyId((pitchClass + 7) % 12, 'major'), keyId((pitchClass + 5) % 12, 'major'), keyId((pitchClass + 9) % 12, 'minor')];
    return [keyId((pitchClass + 7) % 12, 'minor'), keyId((pitchClass + 5) % 12, 'minor'), keyId((pitchClass + 3) % 12, 'major')];
  }

  function distancesFrom(id) {
    const distances = new Map([[id, 0]]);
    let frontier = [id];
    while (frontier.length) {
      const farther = [];
      frontier.forEach(key => closelyRelated(key).forEach(neighbour => {
        if (distances.has(neighbour)) return;
        distances.set(neighbour, distances.get(key) + 1);
        farther.push(neighbour);
      }));
      frontier = farther;
    }
    return distances;
  }

  function pathBetween(from, to, random = Math.random) {
    const distances = distancesFrom(to);
    const path = [from];
    while (path[path.length - 1] !== to) {
      const current = path[path.length - 1];
      const closer = closelyRelated(current).filter(key => distances.get(key) === distances.get(current) - 1);
      path.push(closer[Math.floor(random() * closer.length)]);
    }
    return path;
  }

  function position(id) {
    const { pitchClass, mode } = parseId(id);
    const majorPitchClass = mode === 'major' ? pitchClass : (pitchClass + 3) % 12;
    const angle = (CIRCLE_OF_FIFTHS.indexOf(majorPitchClass) / 12) * Math.PI * 2 - Math.PI / 2;
    const radius = mode === 'major' ? OUTER_RADIUS : INNER_RADIUS;
    return [Math.cos(angle) * radius, Math.sin(angle) * radius];
  }

  function element(parent, name, attributes, text) {
    const node = document.createElementNS(SVG_NS, name);
    Object.entries(attributes).forEach(([attribute, value]) => node.setAttribute(attribute, value));
    if (text !== undefined) node.textContent = text;
    parent.appendChild(node);
    return node;
  }

  const ALL_KEYS = ['major', 'minor'].flatMap(mode => CIRCLE_OF_FIFTHS.map(pitchClass => keyId(pitchClass, mode)));

  function renderWheel(svg, { from, path = [], onSelect, caption }) {
    svg.innerHTML = '';
    svg.setAttribute('viewBox', '-260 -260 520 520');
    const distances = distancesFrom(from);
    const defs = element(svg, 'defs', {});
    defs.innerHTML = '<linearGradient id="trail" x1="0" x2="1"><stop offset="0" stop-color="#4ef2ff"/><stop offset="1" stop-color="#ff6fe0"/></linearGradient>';
    [OUTER_RADIUS + 22, (OUTER_RADIUS + INNER_RADIUS) / 2, INNER_RADIUS - 30].forEach((radius, index) =>
      element(svg, 'circle', { r: radius, fill: 'none', stroke: '#222a5c', 'stroke-dasharray': index === 1 ? '2 6' : '' }));
    if (path.length > 1) {
      element(svg, 'polyline', { points: path.map(key => position(key).join(',')).join(' '), fill: 'none', stroke: 'url(#trail)', 'stroke-width': 3, 'stroke-linecap': 'round', 'stroke-linejoin': 'round' });
    }
    ALL_KEYS.forEach(id => {
      const [x, y] = position(id);
      const onPath = path.includes(id);
      const isMajor = parseId(id).mode === 'major';
      const node = element(svg, 'g', { class: 'node', tabindex: onSelect ? 0 : -1, role: onSelect ? 'button' : 'img', 'aria-label': `${keyName(id)}, ${distances.get(id)} steps from ${keyName(from)}` });
      const fill = id === from ? '#ffd166' : onPath ? '#161b3a' : '#0b0e1f';
      const stroke = id === from ? '#ffd166' : onPath ? '#4ef2ff' : '#2e3878';
      element(node, 'circle', { cx: x, cy: y, r: isMajor ? (onPath ? 22 : 19) : (onPath ? 18 : 15), fill, stroke, 'stroke-width': onPath ? 2 : 1 });
      element(node, 'text', { x, y: y + (isMajor ? 5 : 4), 'text-anchor': 'middle', 'font-size': isMajor ? 14 : 11, fill: id === from ? '#05060d' : onPath ? '#eef0ff' : '#9aa1d4', 'font-weight': onPath || id === from ? 600 : 400 }, shortName(id));
      if (onSelect) {
        node.addEventListener('click', event => onSelect(id, event));
        node.addEventListener('keydown', event => { if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); onSelect(id, event); } });
      }
    });
    if (caption) {
      element(svg, 'text', { x: 0, y: -8, 'text-anchor': 'middle', 'font-size': 12, fill: '#9aa1d4', 'letter-spacing': 2 }, caption.top);
      element(svg, 'text', { x: 0, y: 18, 'text-anchor': 'middle', 'font-size': 24, fill: '#ffd166', 'font-weight': 600 }, caption.bottom);
    }
  }

  window.KeyGraph = { closelyRelated, distancesFrom, pathBetween, keyName, shortName, idFromName, renderWheel, ALL_KEYS };
})();
