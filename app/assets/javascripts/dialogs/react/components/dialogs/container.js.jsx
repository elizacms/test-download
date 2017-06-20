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
console.log( "Create or Update Dialog" );
console.log( data );
console.log( this.state.data );
    if (this.state.isUpdate) {
      var url = '/dialogue_api/response?id=' + this.state.currentDialogId.$oid;
      const current_data = this.state.data;
      const tmp = current_data.filter( (f) => f.id != this.state.currentDialogId );
      this.setState({
        data: [...tmp, data]
      }, () => this.callDialogApi(url) );

    } else {
      var url = '/dialogue_api/response?';

      this.setState({
        data: [...this.state.data, data]
      }, () => this.callDialogApi(url) );
    }

    IAM.loading.start({ type:'logo', duration: false });
  },

  callDialogApi(url){
    console.log("Ajaxing....");
    
    var ajaxData = JSON.stringify({ intent_id: this.props.intent_id,
                                    dialogs: this.state.data });
    console.log( ajaxData );

    $.ajax({
      type: 'POST',
      url: url,
      dataType: 'json',
      contentType: 'application/json',
      data: ajaxData
    })
    .done( function( data ){
      var form = $('form');
      form.find( 'input' ).val( '' );
      form.find( 'select' ).val( '' );

      $('.iam-loading').each(function(){
          IAM.loading.stop({id: $(this).attr('rel')});
      });

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
      this.setState({ data: data }, ()=>{
        console.log( "All Scenarios!" );
        console.log( data );
      });
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

  copyData(data){
    // remove responses ids from the original
    for(var i=0; i<data.responses.length; i++){
      data.responses[i].id="";
    }

    this.setState({dialogData: data, isUpdate: false, currentDialogId: null});
  },

  deleteRow(dialogData, rowIndex){
    let stateData = this.state.data;

    stateData.splice(rowIndex, 1);

    this.setState({
      data: stateData
    });

    $.ajax({
      type: 'DELETE',
      url: '/dialogue_api/response?id=' + dialogData.id.$oid
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
        <ExportCSV
          skill_name={this.props.skill_name}
          intent_id={this.props.intent_id}
          web_hook={this.props.web_hook}
          >
        </ExportCSV>

        <Table
          locked={this.props.file_lock}
          sendData={this.sendData}
          copyData={this.copyData}
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
          isUpdate={this.state.isUpdate}
        ></DialogForm>
      </div>
    );
  }
});
