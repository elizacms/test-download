import React, { Component } from 'react';
import throttle from 'lodash/throttle';
import { stateToHTML } from 'draft-js-export-html';
import toMarkdown from 'to-markdown';

import ee from '../../EventEmitter';

import {
  AtomicBlockUtils,
  CompositeDecorator,
  ContentState,
  Editor,
  EditorState,
  RichUtils
} from 'draft-js';

import Media from './Media';
import Link from './Link';
import BlockStyleControls from './BlockStyleControls';
import InlineStyleControls from './InlineStyleControls';

export default class TextEditor extends Component {
  constructor(props) {
    super(props);

    const addLinkDecorator = new CompositeDecorator([
      { strategy: findLinkEntities, component: Link },
      { strategy: findImageEntities, component: Image},
    ]);

    this.ee = ee; ''
    this.state = {
      index: props.index,
      editorState: EditorState.set(props.editorState, {decorator: addLinkDecorator}),
      showURLInput: false,
      showImageInput: false,
      showVideoInput: false,
      showPagePushInput: false,
      showWaitTimeInput: false,
      urlValue: '',
      urlType: '',
    };

    this.focus = () => this.editor && this.editor.focus();
    this.onChange = this.onChange.bind(this);
    this.throttledOnChange = throttle(this.throttledOnChange.bind(this), 75);
    this.handleKeyCommand = this.handleKeyCommand.bind(this);
    this.onTab = this.onTab.bind(this);
    this.toggleBlockType = this.toggleBlockType.bind(this);
    this.toggleInlineStyle = this.toggleInlineStyle.bind(this);
    this.promptForLink = this.promptForLink.bind(this);
    this.confirmLink = this.confirmLink.bind(this);
    this.promptForImage = this.promptForImage.bind(this);
    this.confirmImage = this.confirmImage.bind(this);
    this.promptForVideo = this.promptForVideo.bind(this);
    this.confirmVideo = this.confirmVideo.bind(this);
    this.promptForPagePush = this.promptForPagePush.bind(this);
    this.confirmPagePush = this.confirmPagePush.bind(this);
    this.promptForWaitTime = this.promptForWaitTime.bind(this);
    this.confirmWaitTime = this.confirmWaitTime.bind(this);
    this.onURLChange = (e) =>  this.setState({urlValue: e.target.value ? e.target.value : '', showURLInput: true});
    this.onURLForImageChange = (e) =>  this.setState({urlValue: e.target.value ? e.target.value : '', showImageInput: true});
    this.onURLForVideoChange = (e) =>  this.setState({urlValue: e.target.value ? e.target.value : '', showVideoInput: true});
    this.onURLForPagePushChange = (e) =>  this.setState({urlValue: e.target.value ? e.target.value : '', showPagePushInput: true});
    this.onWaitTimeChange = (e) =>  this.setState({urlValue: e.target.value ? e.target.value : '', showWaitTimeInput: true});
    this.onLinkInputKeyDown = this.onLinkInputKeyDown.bind(this);
    this.removeLink = this.removeLink.bind(this);
    this.handleMouseOver = this.handleMouseOver.bind(this);
    this.throttledHandleMouseOver = throttle(this.throttledHandleMouseOver, 75).bind(this);
  }

  render() {
    let urlInput = null;
    let imageInput = null;
    let videoInput = null;
    let pagePushInput = null;
    let waitTimeInput = null;
    const {editorState} = this.state;
    if(!editorState) return null;
    // If the user changes block type before entering any text, we can
    // either style the placeholder or hide it. Let's just hide it now.
    let className = 'RichEditor-editor';
    var contentState = editorState.getCurrentContent();
    if (!contentState.hasText()) {
      if (contentState.getBlockMap().first().getType() !== 'unstyled') {
        className += ' RichEditor-hidePlaceholder';
      }
    }

    if (this.state.showURLInput) {
      urlInput = (
        <div style={styles.urlInputContainer}>
          <form onSubmit={this.confirmLink}>
            <p>Add Url (http://example.com):</p>
            <input
              onInput={this.onURLChange}
              ref={ urlComponent => this.urlComponent = urlComponent }
              style={styles.urlInput}
              type="text"
              value={this.state.urlValue}
              onKeyDown={this.onLinkInputKeyDown}
            />
            <button onClick={this.confirmLink }>Confirm</button>
          </form>
        </div>
      );
    }

    if (this.state.showImageInput) {
      imageInput =
        <div style={styles.urlInputContainer}>
          <form onSubmit={this.onURLForImageChange}>
            <p>Add Src (http://example.com):</p>
            <input
              onInput={this.onURLForImageChange}
              ref={ imageComponent => this.imageComponent = imageComponent }
              style={styles.urlInput}
              type="text"
              value={this.state.urlValue}
              onKeyDown={this.onImageInputKeyDown}
            />
            <button onClick={this.confirmImage}>Confirm</button>
          </form>
        </div>;
    }

    if (this.state.showVideoInput) {
      videoInput =
        <div style={styles.urlInputContainer}>
          <form onSubmit={this.onURLForVideoChange}>
            <p>Add Src (http://example.com):</p>
            <input
              onInput={this.onURLForVideoChange}
              ref={ videoComponent => this.videoComponent = videoComponent }
              style={styles.urlInput}
              type="text"
              value={this.state.urlValue}
              onKeyDown={this.onVideoInputKeyDown}
            />
            <button onClick={this.confirmVideo}>Confirm</button>
          </form>
        </div>;
    }

    if (this.state.showPagePushInput) {
      pagePushInput =
        <div style={styles.urlInputContainer}>
          <form onSubmit={this.onURLForPagePushChange}>
            <p>Add Src (http://example.com):</p>
            <input
              onInput={this.onURLForPagePushChange}
              ref={ pagePushComponent => this.pagePushComponent = pagePushComponent }
              style={styles.urlInput}
              type="text"
              value={this.state.urlValue}
              onKeyDown={this.onPagePushInputKeyDown}
            />
            <button onClick={this.confirmPagePush}>Confirm</button>
          </form>
        </div>;
    }

    if (this.state.showWaitTimeInput) {
      waitTimeInput =
        <div style={styles.urlInputContainer}>
          <form onSubmit={this.confirmWaitTime}>
            <p>Add Src (http://example.com):</p>
            <input
              onInput={this.onWaitTimeChange}
              ref={ waitTimeComponent => this.waitTimeComponent = waitTimeComponent }
              style={styles.urlInput}
              type="text"
              value={this.state.urlValue}
              onKeyDown={this.onWaitTimeInputKeyDown}
            />
            <button onClick={this.confirmWaitTime}>Confirm</button>
          </form>
        </div>;
    }

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
        {
            <div style={styles.buttons}>
            <button
              onMouseDown={this.promptForLink}
              className='RichEditor-styleButton'
              style={{marginRight: 10}}
            >
              Add Link
            </button>
            <button
              className='RichEditor-styleButton'
              onMouseDown={this.removeLink}
            >
            Remove Link
            </button>
            </div>
        }
        {

            <button
              onMouseDown={this.promptForWaitTime}
              className='RichEditor-styleButton'
              style={{marginRight: 10}}
            >
            Add Wait Time
            </button>
        }
        {

            <button
              onMouseDown={this.promptForImage}
              className='RichEditor-styleButton'
              style={{marginRight: 10}}
            >
            Add Image
            </button>
        }
        {

            <button
              onMouseDown={this.promptForVideo}
              className='RichEditor-styleButton'
              style={{marginRight: 10}}
            >
            Add Video
            </button>
        }
        {

            <button
              onMouseDown={this.promptForPagePush}
              className='RichEditor-styleButton'
              style={{marginRight: 10}}
            >
            Add PagePush Url
            </button>
        }
        {

            <button
              onMouseDown={this.promptForWaitTime}
              className='RichEditor-styleButton'
              style={{marginRight: 10}}
            >
            Add Wait Time
            </button>
        }
        <div>
          {urlInput}
          {imageInput}
          {videoInput}
          {pagePushInput}
          {waitTimeInput}
        </div>
        <div tabIndex={0}
          onMouseOver={this.handleMouseOver}
          onClick={this.focus}
        >
        {
          !urlInput && !imageInput && !videoInput && !pagePushInput && !waitTimeInput && (
            <Editor
              blockStyleFn={getBlockStyle}
              blockRendererFn={mediaBlockRenderer}
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
    this.focus();
  }

  promptForLink(e) {
    e.preventDefault();
    const {editorState} = this.state;
    const selection = editorState.getSelection();

    const createLinkEntity = () => {
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
        this.setState({
          showURLInput: true,
          urlValue: url,
        }, () => {
          this.urlComponent && this.urlComponent.focus();
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

  promptForImage(e) {
    e.preventDefault();
    const {editorState} = this.state;
    const selection = editorState.getSelection();

    const createImageEntity = () => {
      if (!selection.isCollapsed()) {
        const contentState = editorState.getCurrentContent();
        const startKey = editorState.getSelection().getStartKey();
        const startOffset = editorState.getSelection().getStartOffset();
        const blockWithImageAtBeginning = contentState.getBlockForKey(startKey);
        const imageKey = blockWithImageAtBeginning.getEntityAt(startOffset);
        let url = '';
        if (imageKey) {
          const imageInstance = contentState.getEntity(imageKey);
          url = imageInstance.getData().url;
        }
        this.setState({
          showImageInput: true,
          urlValue: url,
          urlType: 'image',
        }, () => {
          this.urlComponent && this.urlComponent.focus();
        });
      }
    }
    this.setState({
          showImageInput: true,
    }, createImageEntity);
  }

  confirmImage(e) {
    e.preventDefault();

    const {editorState, urlValue} = this.state;
    const contentState = editorState.getCurrentContent();
    const contentStateWithEntity = contentState.createEntity(
      'image',
      'IMMUTABLE',
      {src: urlValue}
    );
    const entityKey = contentStateWithEntity.getLastCreatedEntityKey();
    const newEditorState = EditorState.set(editorState, { currentContent: contentStateWithEntity });

    let text = stateToHTML(this.state.editorState.getCurrentContent()) || '';
    let imageUrlData = {
      text,
      url: urlValue,
      index: this.state.index,
    }
    this.ee.emit('addImageUrl', imageUrlData);
    this.setState({
      showImageInput: false,
      urlValue: '',
    }, this.focus)
  }

  promptForVideo(e) {
    e.preventDefault();
    const {editorState} = this.state;
    const selection = editorState.getSelection();

    const createVideoEntity = () => {
      if (!selection.isCollapsed()) {
        const contentState = editorState.getCurrentContent();
        const startKey = editorState.getSelection().getStartKey();
        const startOffset = editorState.getSelection().getStartOffset();
        const blockWithVideoAtBeginning = contentState.getBlockForKey(startKey);
        const videoKey = blockWithVideoAtBeginning.getEntityAt(startOffset);
        let url = '';

        if (videoKey) {
          const videoInstance = contentState.getEntity(videoKey);
          url = videoInstance.getData().url;
        }

        this.setState({
          showVideoInput: true,
          urlValue: url,
          urlType: 'video',
        }, () => {
          this.videoComponent && this.videoComponent.focus();
        });

      }
    }

    this.setState({ showVideoInput: true }, createVideoEntity);
  }

  confirmVideo(e) {
    e.preventDefault();

    const {editorState, urlValue} = this.state;
    const contentState = editorState.getCurrentContent();
    const contentStateWithEntity = contentState.createEntity(
      'video',
      'IMMUTABLE',
      {src: urlValue}
    );
    const entityKey = contentStateWithEntity.getLastCreatedEntityKey();
    const newEditorState = EditorState.set(editorState, { currentContent: contentStateWithEntity });

    let text = stateToHTML(this.state.editorState.getCurrentContent());
    let videoUrlData = {
      text,
      url: urlValue,
      index: this.state.index,
    }
    this.ee.emit('addVideoUrl', videoUrlData);

    this.setState({
      editorState: AtomicBlockUtils.insertAtomicBlock(newEditorState, entityKey, ' ',),
      showVideoInput: false,
      urlValue: '',
    }, this.focus)
  }

  promptForPagePush(e) {
    e.preventDefault();
    const {editorState} = this.state;
    const selection = editorState.getSelection();

    const createPagePushEntity = () => {
      if (!selection.isCollapsed()) {
        const contentState = editorState.getCurrentContent();
        const startKey = editorState.getSelection().getStartKey();
        const startOffset = editorState.getSelection().getStartOffset();
        const blockWithPagePushAtBeginning = contentState.getBlockForKey(startKey);
        const pagePushKey = blockWithPagePushAtBeginning.getEntityAt(startOffset);
        let url = '';

        if (pagePushKey) {
          const pagePushInstance = contentState.getEntity(pagePushKey);
          url = pagePushInstance.getData().url;
        }

        this.setState({
          showPagePushInput: true,
          urlValue: url,
          urlType: 'pagepush',
        }, () => {
          this.pagePushComponent && this.pagePushComponent.focus();
        });

      }
    }

    this.setState({ showPagePushInput: true }, createPagePushEntity);
  }

  confirmPagePush(e) {
    e.preventDefault();

    const {editorState, urlValue} = this.state;
    const contentState = editorState.getCurrentContent();
    const contentStateWithEntity = contentState.createEntity(
      'pagepush',
      'IMMUTABLE',
      {src: urlValue}
    );
    const entityKey = contentStateWithEntity.getLastCreatedEntityKey();
    const newEditorState = EditorState.set(editorState, { currentContent: contentStateWithEntity });

    let text = stateToHTML(this.state.editorState.getCurrentContent());
    let pagePushUrlData = {
      text,
      url: urlValue,
      index: this.state.index,
    }
    this.ee.emit('addPagePushUrl', pagePushUrlData);

    this.setState({
      editorState: AtomicBlockUtils.insertAtomicBlock(newEditorState, entityKey, ' ',),
      showPagePushInput: false,
      urlValue: '',
    }, this.focus)
  }



  promptForWaitTime(e) {
    e.preventDefault();
    const {editorState} = this.state;
    const selection = editorState.getSelection();

    const createWaitTimeEntity = () => {
      if (!selection.isCollapsed()) {
        const contentState = editorState.getCurrentContent();
        const startKey = editorState.getSelection().getStartKey();
        const startOffset = editorState.getSelection().getStartOffset();
        const blockWithWaitTimeAtBeginning = contentState.getBlockForKey(startKey);
        const waitTimeKey = blockWithWaitTimeAtBeginning.getEntityAt(startOffset);
        let url = '';

        if (waitTimeKey) {
          const waitTimeInstance = contentState.getEntity(waitTimeKey);
          url = waitTimeInstance.getData().url;
        }

        this.setState({
          showWaitTimeInput: true,
          urlValue: url,
          urlType: 'waittime',
        }, () => {
          this.waitTimeComponent && this.waitTimeComponent.focus();
        });

      }
    }

    this.setState({ showWaitTimeInput: true }, createWaitTimeEntity);
  }

  confirmWaitTime(e) {
    e.preventDefault();

    const {editorState, urlValue} = this.state;
    const contentState = editorState.getCurrentContent();
    const contentStateWithEntity = contentState.createEntity(
      'waittime',
      'IMMUTABLE',
      {src: urlValue}
    );
    const entityKey = contentStateWithEntity.getLastCreatedEntityKey();
    const newEditorState = EditorState.set(editorState, { currentContent: contentStateWithEntity });

    let text = toMarkdown(stateToHTML(this.state.editorState.getCurrentContent()));
    let waitTimeData = {
      text,
      url: urlValue,
      index: this.state.index,
    }

    this.setState({
      editorState: AtomicBlockUtils.insertAtomicBlock(newEditorState, entityKey, ' ',),
      showWaitTimeInput: false,
      urlValue: '',
    }, () => {

this.focus();
    this.ee.emit('addWaitTime', waitTimeData);
    })
  }
}

function mediaBlockRenderer(block) {
        if (block.getType() === 'atomic') {
          return {
            component: Media,
            editable: false,
          };
        }
        return null;
      }
// Custom overrides for "code" style.

function getBlockStyle(block) {
  switch (block.getType()) {
    case 'blockquote': return 'RichEditor-blockquote';
    default: return null;
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
    }, callback
  );
}


function findImageEntities(contentBlock, callback, contentState) {
  contentBlock.findEntityRanges(
    (character) => {
      const entityKey = character.getEntity();
      return (
        entityKey !== null &&
        contentState.getEntity(entityKey).getType() === 'image'
      );
    },
    callback
  );
}

function findVideoEntities(contentBlock, callback, contentState) {
  contentBlock.findEntityRanges(
    (character) => {
      const entityKey = character.getEntity();
      return (
        entityKey !== null &&
        contentState.getEntity(entityKey).getType() === 'video'
      );
    },
    callback
  );
}
const styles = {
  root: {
    fontFamily: '\'Georgia\', serif',
    padding: 20,
    width: 600,
  },
  buttons: {
    display: 'inline-block',
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
};



