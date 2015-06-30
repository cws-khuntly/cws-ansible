require('msys.core');
require('msys.datasource');
require('msys.db');
-- set some local variables to use
local success, errmsg, row;
local cache, query, raise_error;
local mod = {};
local auth = {};
local q_params = {};
-- should be in a client vars file, but until I know how to do that, lets put it in here
local default_domain = "cableone.net";

function auth:authenticate(filename, paramsdict, username, password)

-- lets take our username, which should be in a form of local-part@domain.tld and break it up into local-part and domain
	local dc,localpart,domain; 
 	for st in string.gmatch(username, "[^@]+" ) do
		if localpart == nil then
			-- first thing will be local-part, store it in localpart variable
			localpart = st;
		elseif domain == nil then
			-- localpart will already be filled so the next iteration lets fill in domain
			domain = st;
		else
			-- should only get here if the user has entered to @'s in their login name, which isn't valid. Fail Auth
  			return msys.core.EC_AUTH_FAIL;
		end
 	end
        if localpart == nil then
                return msys.core.EC_AUTH_FAIL;
        end
        if string.match(localpart, "\.("..default_domain..")$") then
                lp = string.gsub(localpart, "\.("..default_domain..")$", "")
                localpart = lp;
        end
	if domain == nil then
		-- If the user hasn't entered a username with a domain, we set the domain to the default_domain
		domain = default_domain;
	end

 	for st in string.gmatch(domain,'[^%.]+') do
		-- loop through the domain changing every . into the equivilant dc= to be used for the bind dn
		if dc == nil then
			dc = "dc=" ..  st; 
		else 
			-- every dc after the first should start with a , to seperate it from the previous
			dc = dc .. "," .. "dc=" .. st; 
		end


 	end

	-- now we have the dc part of the bind string, lets build the full bind stiring
	q_params["dn"] = "uid=" .. localpart .. ",ou=people," .. dc;
	password = string.gsub(password, "([,?$:%%])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
	-- fill in variables for our cache name in ecelerity, the query string, and the paramters we gathered above 
	cachename = "ldap_bind_auth";
	query = "ldap:///?dn?sub?(&(zimbraMailStatus=enabled)(zimbraAccountStatus=active)(dn='$dn'))?x-ldap-version=3,bindname=$dn,x-bindpw=" .. password

-- log all these variables

	local text_log_data = "cachename = " .. cachename .. "\n" .. "query = " .. query .. "\n" .. "dn = " .. q_params["dn"] .. "\n" .. "password = " .. password .. "\n";
	print(text_log_data);
	
	-- issue the db.query to query the datastore to attempt to bind as the user
	success, errmsg = msys.db.query(cachename,query,q_params,{ raise_error = false }); 
--	print(success);
--	print(errmsg);

--	for row in success do
--		print (row[1]);
--	end

	if (success == nil) then
  		return msys.core.EC_AUTH_FAIL;
  	else
		-- bind succeeded, send back the AUTH OK
		return msys.core.EC_AUTH_OK;
  	end
end

function mod:init()
  -- must be called from an init routine
  msys.registerAuth("cableoneauth", auth);
  return true;
end;

msys.registerModule("myauth", mod);
