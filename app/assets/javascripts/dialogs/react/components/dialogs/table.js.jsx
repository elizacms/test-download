var Table = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  showDialogForm(){
    $('.dialogForm').show();
    $('.dialogTable').hide();
    $('.exportCSV').hide();
  },

  render() {
    return (
      <div className='dialogTable'>
        <table className='dialogs'>
          <tbody>
            <tr>
              <th className='row5'>&nbsp;Priority</th>
              <th className='row20'>Response</th>
              <th className='row12'>Unresolved</th>
              <th className='row12'>Missing</th>
              <th className='row12'>Awaiting Field</th>
              <th className='row12'>Entity Values</th>
              <th className='row12'>Present</th>
              <th className='row8'>Options</th>
            </tr>
            {
              this.props.data.map(function(dialog, index){
                return <TableRow
                          sendData={this.props.sendData}
                          copyData={this.props.copyData}
                          deleteRow={this.props.deleteRow}
                          data={dialog}
                          key={index}
                          itemIndex={index}
                        >{dialog}</TableRow>;
              }.bind(this))
            }
          </tbody>
        </table>
        <button
          className='btn lg ghost pull-right'
          onClick={this.showDialogForm}
        >
          Create a Dialog
        </button>
      </div>
    );
  }
});
