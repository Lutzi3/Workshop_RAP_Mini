@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Root View RAP'
@Metadata.allowExtensions: true
// Basis für RAP Workshop
// Select Geschäftspartner und Adresse falls vorhanden
define root view entity ZRAP_I_DDL_LUTZ
  as select from    but000
    left outer join but020 on but000.partner = but020.partner
    association to adrc                  on  adrc.addrnumber = but020.addrnumber
                                       and adrc.date_from  = but020.date_from
                                       and adrc.nation     = but020.nation
                                       
    association to I_Country as _Country on  _Country.Country = $projection.country

 
{

  key but000.partner,
  key but020.addrnumber,
      but000.type,
      but000.bu_group,
      but000.bpext,
      but000.bu_sort1,
      but000.title,

      // A new field is calculated depending of the BP type (person or organization) and by
      // concatenating the corresponding name fields
      case when but000.type = '1' then concat_with_space(but000.name_first, but000.name_last, 1)
           else concat_with_space(but000.name_org1, but000.name_org2, 1)
           end as Name_BuPa,

      but000.name_org1,
      but000.name_org2,
      but000.name_last,
      but000.name_first,
      but000.crusr,
      but000.crdat,
      but000.crtim,
      but000.chusr,
      but000.chdat,
      but000.chtim,


      adrc.city1,
      adrc.post_code1,
      adrc.street,
      adrc.house_num1,
      @Consumption.valueHelpDefinition: [{entity:{element:'Country', name:'I_Country'} }]
      adrc.country,

      _Country // Make association public
}
