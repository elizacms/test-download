import StyleButton from '../StyleButton';

const BLOCK_TYPES = [
  {label: 'Blockquote', style: 'blockquote'},
  {label: 'List', style: 'unordered-list-item'},
];

export default function BlockStyleControls (props) {
  const {editorState} = props;
  const selection = editorState.getSelection();
  const blockType = editorState
    .getCurrentContent()
    .getBlockForKey(selection.getStartKey())
    .getType();

  return (
    <div className="RichEditor-controls">
    {
      BLOCK_TYPES.map((type) => (
        <StyleButton
          key={type.label}
          active={type.style === blockType}
          label={type.label}
          onToggle={props.onToggle}
          style={type.style}
        />
      ))
    }
    </div>
  );
}
