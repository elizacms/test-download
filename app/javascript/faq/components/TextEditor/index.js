import React, { Component } from 'react';
import { CompositeDecorator, ContentState, Editor, EditorState, RichUtils, convertFromRaw } from 'draft-js';
import throttle from 'lodash/throttle';

const styles = {
  root: {
    fontFamily: '\'Georgia\', serif',
    padding: 20,
    width: 600,
  },
  buttons: {
    marginBottom: 10,
  },
  urlInputContainer: {
    marginBottom: 10,
  },
  urlInput: {
    fontFamily: '\'Georgia\', serif',
    marginRight: 10,
    padding: 3,
  },
  editor: {
    border: '1px solid #ccc',
    cursor: 'text',
    minHeight: 80,
    padding: 10,
  },
  button: {
    marginTop: 10,
    textAlign: 'center',
  },
  link: {
    color: '#3b5998',
    textDecoration: 'underline',
  },
};

export default class TextEditor extends Component {
  constructor(props) {
    super(props);

    const addLinkDecorator = new CompositeDecorator([
      { strategy: findLinkEntities, component: Link },
    ]);

    this.state = {
      editorState: EditorState.set(props.editorState, {decorator: addLinkDecorator}),
      showURLInput: false,
      urlValue: '',
    };


    this.focus = () => this.editor && this.editor.focus();
    this.onChange = this.onChange.bind(this);
    this.throttledOnChange = throttle(this.throttledOnChange.bind(this), 75);
    this.handleKeyCommand = this.handleKeyCommand.bind(this);
    this.onTab = this.onTab.bind(this);
    this.toggleBlockType = this.toggleBlockType.bind(this);
    this.toggleInlineStyle = this.toggleInlineStyle.bind(this);
    this.promptForLink = this.promptForLink.bind(this);
    this.onURLChange = (e) =>  this.setState({urlValue: e.target.value ? e.target.value : '', showURLInput: true});
    this.confirmLink = this.confirmLink.bind(this);
    this.onLinkInputKeyDown = this.onLinkInputKeyDown.bind(this);
    this.removeLink = this.removeLink.bind(this);
    this.handleMouseOver = this.handleMouseOver.bind(this);
    this.throttledHandleMouseOver = throttle(this.throttledHandleMouseOver, 75).bind(this);
  }

  onChange(editorState) {
    this.throttledOnChange(editorState);
  }

  throttledOnChange(editorState) {
    let content = editorState.getCurrentContent();

    if(editorState) {
      this.setState({ editorState }, () => {
        this.props.handleChange(this.state.editorState, this.props.index)
      });
    }
  }


  handleKeyCommand(command) {
    const {editorState} = this.state;
    const newState = RichUtils.handleKeyCommand(editorState, command);
    if (newState) {
      this.onChange(newState);
      return true;
    }
    return false;
  }

  onTab(e) {
    const maxDepth = 4;
    this.onChange(RichUtils.onTab(e, this.state.editorState, maxDepth));
  }

  toggleBlockType(blockType) {
    this.onChange(
      RichUtils.toggleBlockType(
        this.state.editorState,
        blockType
      )
    );
  }

  toggleInlineStyle(inlineStyle) {
    this.onChange(
      RichUtils.toggleInlineStyle(
        this.state.editorState,
        inlineStyle
      )
    );
  }

  handleMouseOver(e) {
    e.persist();
    this.throttledHandleMouseOver(e);
  }

  throttledHandleMouseOver(e) {
    console.log('throttledHandleMouseOver', e.target);
    this.focus();

  }

  promptForLink(e) {
    e.preventDefault();
    const {editorState} = this.state;
    const selection = editorState.getSelection();

    function createLinkEntity() {
      if (!selection.isCollapsed()) {
        const contentState = editorState.getCurrentContent();
        const startKey = editorState.getSelection().getStartKey();
        const startOffset = editorState.getSelection().getStartOffset();
        const blockWithLinkAtBeginning = contentState.getBlockForKey(startKey);
        const linkKey = blockWithLinkAtBeginning.getEntityAt(startOffset);
        let url = '';
        if (linkKey) {
          const linkInstance = contentState.getEntity(linkKey);
          url = linkInstance.getData().url;
        }
        let that = this;
        this.setState({
          showURLInput: true,
          urlValue: url,
        }, () => {
          that.urlComponent && that.urlComponent.focus();
        });
      }

    }
      this.setState({
        showURLInput: true,
      }, createLinkEntity);
  }

  confirmLink(e) {
    e.preventDefault();
    const {editorState, urlValue} = this.state;
    const contentState = editorState.getCurrentContent();
    const contentStateWithEntity = contentState.createEntity(
      'LINK',
      'MUTABLE',
      {url: urlValue}
    );
    const entityKey = contentStateWithEntity.getLastCreatedEntityKey();
    const newEditorState = EditorState.set(editorState, { currentContent: contentStateWithEntity });

    this.setState({
      editorState: RichUtils.toggleLink(
        newEditorState,
        newEditorState.getSelection(),
        entityKey
      ),
      showURLInput: false,
      urlValue: '',
    }, this.focus )

  }
  onLinkInputKeyDown(e) {
    if (e.which === 13) {
      this.confirmLink(e);
    }
  }
  removeLink(e) {
    e.preventDefault();
    const {editorState} = this.state;
    const selection = editorState.getSelection();
    if (!selection.isCollapsed()) {
      this.setState({
        editorState: RichUtils.toggleLink(editorState, selection, null),
      });
    }
  }
  render() {
    let urlInput = null;
    const {editorState} = this.state;
    if(!editorState) return null;
    // If the user changes block type before entering any text, we can
    // either style the placeholder or hide it. Let's just hide it now.
    if (this.state.showURLInput) {
      urlInput =
        <div style={styles.urlInputContainer}>
        <form onSubmit={this.onURLChange}>
        <p>Add Url (http://example.com):</p>
          <input
            onInput={this.onURLChange}
            ref={ urlComponent => this.urlComponent = urlComponent }
            style={styles.urlInput}
            type="text"
            value={this.state.urlValue}
            onKeyDown={this.onLinkInputKeyDown}
          />
          <button onClick={this.confirmLink}>
          Confirm
          </button>
          </form>
        </div>;
    }
    let className = 'RichEditor-editor';
    var contentState = editorState.getCurrentContent();
    if (!contentState.hasText()) {
      if (contentState.getBlockMap().first().getType() !== 'unstyled') {
        className += ' RichEditor-hidePlaceholder';
      }
    }

    return (
      <div className="RichEditor-root">
        <InlineStyleControls
          editorState={editorState}
          onToggle={this.toggleInlineStyle}
        />
        <BlockStyleControls
          editorState={editorState}
          onToggle={this.toggleBlockType}
        />
        {urlInput}
        {
          !urlInput && (
            <div style={styles.buttons}>
              <button
                onMouseDown={this.promptForLink}
                style={{marginRight: 10}}
              >
                Add Link
              </button>
              <button onMouseDown={this.removeLink}>
                Remove Link
              </button>
            </div>
          )
        }
        <div tabIndex={0}
          onMouseOver={this.handleMouseOver}
          onClick={this.focus}
        >
        {
          !urlInput &&  (

            <Editor
              blockStyleFn={getBlockStyle}
              tabIndex={0}
              editorState={editorState}
              handleKeyCommand={this.handleKeyCommand}
              onChange={this.onChange}
              onTab={this.onTab}
              placeholder="Tell a story."
              ref={ editor => this.editor = editor }
          />

          )
        }
    </div>
      </div>
    );
  }
}

// Custom overrides for "code" style.

function getBlockStyle(block) {
  switch (block.getType()) {
    case 'blockquote': return 'RichEditor-blockquote';
    default: return null;
  }
}

class StyleButton extends React.Component {
  constructor() {
    super();
    this.onToggle = (e) => {
      e.preventDefault();
      this.props.onToggle(this.props.style);
    };
  }

  render() {
    let className = 'RichEditor-styleButton';

    if (this.props.active) {
      className += ' RichEditor-activeButton';
    }
    return (
      <span className={className} onMouseDown={this.onToggle}>
      {this.props.label}
      </span>
    );
  }
}

function findLinkEntities(contentBlock, callback, contentState) {
  contentBlock.findEntityRanges(
    (character) => {
      const entityKey = character.getEntity();
      return (
        entityKey !== null &&
        contentState.getEntity(entityKey).getType() === 'LINK'
      );
    },
    callback
  );
}

const Link = (props) => {
  const {url} = props.contentState.getEntity(props.entityKey).getData();
  return (
    <a href={url} style={styles.link}>
    {props.children}
    </a>
  );
};

const BLOCK_TYPES = [
  {label: 'Blockquote', style: 'blockquote'},
  {label: 'List', style: 'unordered-list-item'},
];

const BlockStyleControls = (props) => {
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
};

var INLINE_STYLES = [
  {label: 'Bold', style: 'BOLD'},
  {label: 'Italic', style: 'ITALIC'},
  {label: 'Underline', style: 'UNDERLINE'},
];

const InlineStyleControls = (props) => {
  var currentStyle = props.editorState.getCurrentInlineStyle();
  return (
    <div className="RichEditor-controls">
    {
      INLINE_STYLES.map(type =>
        <StyleButton
          key={type.label}
          active={currentStyle.has(type.style)}
          label={type.label}
          onToggle={props.onToggle}
          style={type.style}
        />
      )
    }
    </div>
  );
};
