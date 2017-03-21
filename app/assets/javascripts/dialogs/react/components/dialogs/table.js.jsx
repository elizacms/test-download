var Table = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  render() {
    return (
      <div>
        <table className='dialogs'>
          <tbody>
            <tr>
              <th className='row4'>&nbsp;Priority</th>
              <th className='row18 text-center'>Response</th>
              <th className='row12'>Unresolved</th>
              <th className='row12'>Missing</th>
              <th className='row12'>Present</th>
              <th className='row12'>Awaiting Field</th>
              <th className='row3'>Options</th>
              <th className='row3'></th>
            </tr>
            {
              this.props.data.map(function(dialog, index){
                return <TableRow
                          sendData={this.props.sendData}
                          deleteRow={this.props.deleteRow}
                          data={dialog}
                          key={index}
                          itemIndex={index}
                        >{dialog}</TableRow>;
              }.bind(this))
            }
          </tbody>
        </table>
      </div>
    );
  }
});
