var DialogForm = React.createClass({
  id: 'dialog-form',

  getInitialState() {
    return this.initialData();
  },

  initialData(){
    return {
      'unresolved-field':     [{id: 0, value: '', inputValue: ''}],
      'missing-field':        [{id: 0, value: '', inputValue: ''}],
      'present-field':        [{id: 0, value: '', inputValue: ''}],
      'awaiting-field':       [{id: 0, value: '', inputValue: ''}],
      'responses_attributes': [{id: 0, value: '', inputValue: '',
                                response_trigger: '', response_id: ''}],
      priority: ''
    };
  },

  propTypes: {
  },

  createNewId(rules, nextProps){
    var ary = [];

    if (nextProps.data[rules]) {
      nextProps.data[rules].forEach(function(value, index){
        ary.push({id: index, value: value});
      });
    }

    return ary;
  },

  createNewIdForPresent(nextProps) {
    if (nextProps.data.present){
      var ary  = [];
      var ary2 = [];
      var res  = [];

      nextProps.data.present.forEach(function(value, index){
        index % 2 == 0 ? ary.push(value) : ary2.push(value);
      });

      ary.forEach(function(value, index){
        var hsh = {};
        hsh['id'] = index;
        hsh['value'] = value;
        hsh['inputValue'] = ary2[index];
        res.push(hsh);
      });

      return res;
    }
  },

  createNewIdForResponses(nextProps) {
    const ary = [];
    if (nextProps.data.responses) {
      nextProps.data.responses.forEach(function(response, index){
        const hsh = {};
        hsh['id'] = index;
        hsh['response_id'] = response.id.$oid;
        hsh['value'] = response.response_type;
        hsh['response_trigger'] = response.response_trigger;
        hsh['inputValue'] = JSON.parse(response.response_value);

        ary.push(hsh);
      });

      return ary;
    }
  },

  componentWillReceiveProps(nextProps) {
    if(Object.keys(nextProps.data).length > 0) {
      this.setState({
        'unresolved-field': this.createNewId('unresolved', nextProps),
        'missing-field':    this.createNewId('missing', nextProps),
        'present-field':    this.createNewIdForPresent(nextProps),
        'awaiting-field':   this.createNewId('awaiting_field', nextProps),
        'responses_attributes': this.createNewIdForResponses( nextProps ),
        priority:           nextProps.data.priority,
        response:           nextProps.data.response,
      });
    } else {
      this.setState(this.initialData());
      this.props.resetIsUpdateState();
    }
  },

  priorityHandleChange(event) {
    this.setState({ priority: event.target.value });
  },

  aneedaSaysHandleChange(event){
    this.setState({ response: event.target.value });
  },

  addRow(key){
    var currentState = this.state;
    var currentKey = currentState[key];

    currentKey.push({
      id: currentKey[currentKey.length - 1].id + 1,
      value: '',
      inputValue: '',
      response_trigger: '',
      response_id: ''
    });

    this.setState(currentState);
  },

  updateState(name, obj){
    this.state[name][obj.id] = obj;
    this.setState({});
  },

  deleteInput(input, key){
    var newState = this.state[key];
    newState.splice(newState.indexOf(input), 1)

    this.setState(this.state);

    if (key === 'responses_attributes' && input['response_id'] !== '' ){
      this.deleteResponse( input['response_id'] );
    }
  },

  deleteResponse(response_id){
    $.ajax({
      type: 'DELETE',
      url: '/dialogue_api/response/' + response_id,
    })
    .done( function( r ){
console.log("-- Delete Response --");
console.log(r);
    })
  },

  resetForm(e){
    e.preventDefault();

    if (confirm("Are you sure you want to clear the fields?")){
      this.props.resetDialogData();
      this.props.resetIsUpdateState();
    }
  },

  parseFormInput(name, hasExtra){
    var ary = [];

   $('form').find( 'select[name="' + name + '-field"]' ).each(function(){
      ary.push($(this).val());
    });

    if (hasExtra){
      ary2 = [];
      $('form').find( 'input[name="' + name + '-value"]' ).each(function(index){
        ary2.push(ary[index]);
        ary2.push($(this).val());
      });
      return ary2;
    }

    return ary;
  },

  parseResponseTypeFormInput(){
    const ary = [];
    const state_responses_attributes = this.state.responses_attributes;
    // const current_dialog_id = this.props.data.id.$oid
    const isUpdate = this.props.isUpdate;

    $('[class^="response-type-row"]').each(function(i, this_row){
      const obj = {};
      const iv_obj = {};
      const state_options = state_responses_attributes[i].inputValue.options;

      // obj[ '$oid' ] = $(this_row).find('.response-id').val();
      // obj[ 'dialog_id' ]       = current_dialog_id;

      if (isUpdate && ($(this_row).find('.response-id').val() != '') ) {
        obj[ 'id' ] = $(this_row).find('.response-id').val();
      }


      obj[ 'response_type' ]   = $(this_row).find('.dialog-select').val();
      obj[ 'response_trigger'] = $(this_row).find('.response_trigger').val();

      $(this_row).find('input').each(function(i, this_input){
        if ( $(this_input).hasClass('response-input') ){
          iv_obj[ $(this_input).attr('name') ] = $(this_input).val();
        }
        if ( $(this_input).hasClass('response-option-input') ){
          iv_obj[ 'options' ] = state_options;
        }
      });

      obj['response_value'] = JSON.stringify(iv_obj);

      ary.push(obj);
    });

    return ary;
  },

  createOrUpdateDialog(e){
    e.preventDefault();
    var data = {};
    var form = $('form');

    data[ 'intent_id'  ] = form.find( 'input[name="intent-id"]'         ).val();
    data[ 'priority'   ] = form.find( 'input[name="priority"]'          ).val();
    data[ 'response'   ] = form.find( 'input[name="response"]'          ).val();

    data[ 'unresolved'     ] = this.parseFormInput('unresolved');
    data[ 'missing'        ] = this.parseFormInput('missing');
    data[ 'present'        ] = this.parseFormInput('present', true);
    data[ 'awaiting_field' ] = this.parseFormInput('awaiting');

    data[ 'responses_attributes' ] = this.parseResponseTypeFormInput();

    // if ( $('.aneeda-says').val().replace( /\s/g, '' ) == '' ){
    //   this.props.messageState({'aneeda-says-error': 'This field cannot be blank.'});

    //   return false;
    // }

    this.props.createOrUpdateDialog(data);
  },

  render() {
    var inputs = [
      {
        name: 'unresolved-field',
        title: 'is unresolved'
      },
      {
        name: 'missing-field',
        title: 'is missing'
      },
      {
        name: 'present-field',
        title: 'is present',
        hasInput: true,
        inputPlaceholder: 'present value',
        inputName: 'present-value'
      },
      {
        name: 'awaiting-field',
        title: 'Awaiting field'
      }
    ];

    return (
      <div>
        <h4 className='inline'>Field Responses</h4>
        <a href={this.props.field_path} className='addField btn md grey pull-right'>Add a field</a>
        <a href='#' onClick={this.resetForm} className='btn md grey pull-right'>Reset fields</a>
        <form className='dialog' method='post' action='/dialogue_api/response'>
          <input type='hidden' name='intent-id' value={this.props.intent_id} />
          <hr className='margin5050'></hr>

          <div className='row'>
            <strong className='two columns margin0'>Priority</strong>
            <input
              className='three columns priority-input'
              name='priority'
              type='number'
              value={this.state.priority}
              onChange={this.priorityHandleChange} />
          </div>

          <Message message={this.props.response} name='aneeda-says-error'>
          </Message>
          <hr className='margin0'></hr>

          <table className='dialog'>
            <tbody>
              {/* ******************************************************** */}
              {this.state['responses_attributes'].map(function(input, index){
                return(
                  <ResponseType
                    key={input.id}
                    index={index}
                    name='responses_attributes'
                    className='response-type-text-with-option'
                    title='Response type'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'responses_attributes')}
                    value={this.state['responses_attributes'][index].value}
                    inputValue={this.state['responses_attributes'][index].inputValue}
                    response_trigger={this.state['responses_attributes'][index].response_trigger}
                    response_id={this.state['responses_attributes'][index].response_id}
                    updateState={this.updateState}
                  ></ResponseType>
                );
              }.bind(this))}
              {/* ********************************************************
              {this.state['responses_attributes'].map(function(input, index){
                return(
                  <ResponseTypeContainer
                    key={input.id}
                    index={index}
                    name='responses_attributes'
                    title='response type'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'responses_attributes')}
                    response_trigger={this.state['responses_attributes'][index].response_trigger}
                    response_id={this.state['responses_attributes'][index].response_id}
                    inputValue={this.state['responses_attributes'][index].inputValue}
                    value={this.state['responses_attributes'][index].value}
                    updateState={this.updateState}
                  ></ResponseTypeContainer>
                );
              }.bind(this))}
              ******************************************************** */}

              {this.state['unresolved-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
                    fields={this.props.fields}
                    name='unresolved-field'
                    title='is unresolved'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'unresolved-field')}
                    value={this.state['unresolved-field'][index].value}
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}
              {this.state['missing-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
                    fields={this.props.fields}
                    name='missing-field'
                    title='is missing'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'missing-field')}
                    value={this.state['missing-field'][index].value}
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}
              {this.state['present-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
                    fields={this.props.fields}
                    name='present-field'
                    title='is present'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'present-field')}
                    hasInput={true}
                    inputName='present-value'
                    inputPlaceholder='present value'
                    inputValue={this.state['present-field'][index].inputValue}
                    value={this.state['present-field'][index].value}
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}
              {this.state['awaiting-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
                    fields={this.props.fields}
                    name='awaiting-field'
                    title='Awaiting field'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'awaiting-field')}
                    value={this.state['awaiting-field'][index].value}
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}
            </tbody>
          </table>

          <button
            onClick={this.createOrUpdateDialog}
            className='btn lg ghost dialog-btn pull-right'
          >{this.props.createOrUpdateBtnText()}</button> &nbsp;
        </form>
      </div>
    );
  }
});
