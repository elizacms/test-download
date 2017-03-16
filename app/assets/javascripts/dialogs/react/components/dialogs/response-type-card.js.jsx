var ResponseTypeCard = React.createClass({
  getInitialState() {
    return {
    };
  },

  render() {
    return(
      <div>
        <label>
          Option &nbsp;
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
