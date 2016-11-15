var ExportCSV = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  getCSV: function (){
    var intent_id = $( 'form' ).children( 'input[name="intent-id"]' ).val();

    window.location.assign( '/dialogue_api/csv?intent_id=' + this.props.intent_id );
  },

  render: function() {
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
