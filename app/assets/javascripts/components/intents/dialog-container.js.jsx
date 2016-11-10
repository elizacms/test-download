var DialogContainer = React.createClass({
  id: 'dialog-container',

  propTypes: {
  },

  getInitialState() {
    return { message: {}, data: [] };
  },

  createDialog(data){
    $.ajax({
      type: 'POST',
      url: '/dialogue_api/response?',
      dataType: 'json',
      data: data
    })
    .done( function( data ){
      var form = $('form');
      form.find( 'input' ).val( '' );
      form.find( 'select' ).val( '' );

      this.getAllScenarios();
    }.bind(this))
    .fail(function(error){
      IAM.alert.run('red', error.getResponseHeader('Warning'), 5000);
    });
  },

  componentDidMount() {
    this.getAllScenarios();
  },

  messageState(message){
    this.setState({ message: message });
  },

  getAllScenarios(){
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
    if(Object.getOwnPropertyNames(this.state.message).length > 0){
      this.timer = setTimeout(function(){
        this.setState({message: {} })
      }.bind(this), 3000);
    }
  },

  componentWillUnmount() {
    window.clearTimeout(this.timer);
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
        message: {'response-message': data}
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
        <DialogMessage message={this.state.message} name='response-message'></DialogMessage>

        <br></br><br></br>
        <DialogForm
          fields={this.props.fields}
          data={this.state.data}
          field_path={this.props.field_path}
          intent_id={this.props.intent_id}
          response={this.state.message}
          createDialog={this.createDialog}
          messageState={this.messageState}
        ></DialogForm>
      </div>
    );
  }
});
