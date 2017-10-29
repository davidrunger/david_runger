export function find(wrapper, enhancedSelector) {
  const selectorMatchData = enhancedSelector.match(/^\s*(\S*):text\((.+)\)$/);
  const basicSelector = selectorMatchData[1];
  const targetText = selectorMatchData[2];

  const matchedBySelector = wrapper.findAll(basicSelector).wrappers;
  return matchedBySelector.filter(_wrapper => _wrapper.text() === targetText);
}
