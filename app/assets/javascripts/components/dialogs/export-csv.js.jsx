var ExportCSV = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  getCSV() {
    var intent_id = $( 'form' ).children( 'input[name="intent-id"]' ).val();

    window.location.assign( '/dialogue_api/csv?intent_id=' + this.props.intent_id );
  },

  render() {
    return (
      <div>
        <button onClick={this.getCSV} className='btn lg ghost export-csv pull-right'>
          Export CSV
        </button>

        <br></br><br></br>
        <hr className='margin0'></hr>
      </div>
    );
  }
});
