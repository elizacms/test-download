var DialogContainer = React.createClass({
  id: 'dialog-container',

  propTypes: {
  },

  getInitialState() {
    return { data: [] };
  },

  componentDidMount() {
    var data = { intent_id: this.props.intent_id };

    $.ajax({
      type: 'GET',
      url:  '/dialogue_api/all_scenarios',
      data: data
    })
    .done( function( data ){
      this.setState({ data: data });
    }.bind(this));
  },

  componentDidUpdate(prevProps, prevState) {
    if(this.state.response){
      alert(this.state.response);
      this.state.response = "";
    }
  },

  deleteRow(dialogData, rowIndex){
    let stateData = this.state.data;

    stateData.splice(rowIndex, 1);

    this.setState({
      data: stateData
    });

    $.ajax({
      type: 'DELETE',
      url: '/dialogue_api/response?response_id=' + dialogData.responses[0].id
    })
    .done( function( data ){
      this.setState({
        response: data
      });
    }.bind(this));
  },

  render: function() {
    return (
      <div>
        <ExportCSV title='Export CSV' intent_id={this.props.intent_id}>
        </ExportCSV>

        <DialogTable deleteRow={this.deleteRow} data={this.state.data}>
        </DialogTable>
      </div>
    );
  }
});
