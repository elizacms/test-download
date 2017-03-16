var ResponseTypeVideo = React.createClass({
  getInitialState() {
    return {
    };
  },

  render() {
    return(
      <div>
        <label>
          Thumbnail &nbsp;
          <input
            className='dialog-input'
            type="text"
            name={`type-${this.props.responseType}`}
          />
        </label>
        &nbsp;&nbsp;
        <label>
          Entity Value &nbsp;
          <input
            className='dialog-input'
            type="text"
            name={`type-${this.props.responseType}`}
          />
        </label>
      </div>
    );
  }
});
