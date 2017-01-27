var Container = React.createClass({
  id: 'dialog-container',

  propTypes: {
  },

  getInitialState() {
    return {
      message: {},
      data: [],
      form: {},
      dialogData: {},
      isUpdate: false,
      currentDialogId: null
    };
  },

  resetIsUpdateState(){
    if (this.state.isUpdate === true){
      this.setState({isUpdate: false});
    }
  },

  resetDialogData(){
    this.setState({dialogData: {}});
  },

  createOrUpdateDialog(data){
    if (this.state.isUpdate) {
      var url = '/dialogue_api/response?response_id=' + this.state.currentDialogId.$oid;
    } else {
      var url = '/dialogue_api/response?';
    }

    $.ajax({
      type: this.state.isUpdate ? 'PUT' : 'POST',
      url: url,
      dataType: 'json',
      data: data
    })
    .done( function( data ){
      var form = $('form');
      form.find( 'input' ).val( '' );
      form.find( 'select' ).val( '' );

      this.resetDialogData();
      this.getAllScenarios();
      this.resetIsUpdateState();
    }.bind(this))
    .fail(function(error){
      IAM.alert.run('red', error.getResponseHeader('Warning'), 5000);
    });
  },

  createOrUpdateBtnText(){
    var text;
    text = this.state.isUpdate == true ? 'Update Dialog' : 'Create Dialog';

    return text;
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

  sendData(data){
    this.setState({dialogData: data, isUpdate: true, currentDialogId: data.id});
  },

  deleteRow(dialogData, rowIndex){
    let stateData = this.state.data;

    stateData.splice(rowIndex, 1);

    this.setState({
      data: stateData
    });

    $.ajax({
      type: 'DELETE',
      url: '/dialogue_api/response?response_id=' + dialogData.id.$oid
    })
    .done( function( data ){
      this.setState({
        message: {'response-message': data}
      });
    }.bind(this));
  },

  render() {
    return (
      <div>
        <ExportCSV intent_id={this.props.intent_id}>
        </ExportCSV>

        <Table
          sendData={this.sendData}
          deleteRow={this.deleteRow}
          data={this.state.data}
        ></Table>
        <Message
          message={this.state.message}
          name='response-message'
        ></Message>

        <br></br><br></br>
        <DialogForm
          fields={this.props.fields}
          data={this.state.dialogData}
          field_path={this.props.field_path}
          intent_id={this.props.intent_id}
          response={this.state.message}
          createOrUpdateDialog={this.createOrUpdateDialog}
          messageState={this.messageState}
          form={this.state.form}
          resetIsUpdateState={this.resetIsUpdateState}
          resetDialogData={this.resetDialogData}
          createOrUpdateBtnText={this.createOrUpdateBtnText}
        ></DialogForm>
      </div>
    );
  }
});
